let myWebSockets = Hashtbl.create 10

let send_message m =
  Hashtbl.to_seq_values myWebSockets
  |> List.of_seq
  |> List.map (Dream.send m)
  |> Lwt.join

let rec listen_to nw req =
  match%lwt Dream.receive (Hashtbl.find myWebSockets nw) with
  | Some message ->
    let%lwt () = send_message message in
    let%lwt () = Dream.sql (Database.add_comment message) req in
    listen_to nw req
  | None ->
    Hashtbl.remove myWebSockets nw;
    Lwt.return ()

let websocket_handler req =
  Dream.websocket (fun websocket ->
      let s = Dream.random 200 in
      Hashtbl.add myWebSockets s websocket;
      listen_to s req)

let connection_middleware handler request =
  match Dream.session "user" request with
  | Some _username -> handler request
  | None ->
    request |> Dream.router [
      Dream.post "/" (fun _r ->
          match%lwt Dream.form request with
          | `Ok ["username", username] ->
            let%lwt b = Database.check_user_password username "AAA" request in
            let%lwt () = if b then Dream.put_session "user" username request else Lwt.return () in
            Dream.empty ~headers:["Location", "/"] `See_Other
          | _ -> Dream.empty ~headers:["Location", "/"] `See_Other);

      Dream.get "/"  (fun _r -> Dream.respond @@ Rendering.login request);
    ] @@ Dream.not_found

let () =
  Dream.run ~https:true ~graceful_stop:false
  @@ Dream.logger
  @@ Dream.sql_pool "sqlite3:db.sqlite"
  @@ Dream.sql_sessions
  @@ connection_middleware
  @@ Dream.router [
    Dream.get "/" (fun r ->
        let%lwt comments = Dream.sql Database.list_comments r in
        Dream.respond @@ Rendering.index r comments);
    Dream.post "/" (fun _r -> Dream.empty ~headers:["Location", "/"] `See_Other);
    Dream.get "/websocket" websocket_handler;
    Dream.get "/static/**" (Dream.static "static/");
  ]
  @@ Dream.not_found;;
