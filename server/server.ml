let post_handler request =
  match%lwt Dream.form request with
  | `Ok [ ("disconnect", _) ] ->
      let%lwt () = Dream.invalidate_session request in
      Dream.empty ~headers:[ ("Location", "/") ] `See_Other
  | _ -> Dream.empty ~headers:[ ("Location", "/") ] `See_Other

let () = print_newline ()

let () =
  Dream.run ~https:false @@ Dream.logger
  @@ Dream.sql_pool "sqlite3:db.sqlite"
  @@ Dream.sql_sessions @@ Connection.connection_middleware
  @@ Dream.router
       [
         Dream.get "/" (fun r ->
             let%lwt comments = Database.list_comments r in
             Dream.respond @@ Rendering.index r comments);
         Dream.post "/" post_handler;
         Dream.get "/websocket" Websocket.websocket_handler;
         Dream.get "/static/**" (Dream.static "static/");
       ]
  @@ Dream.not_found
