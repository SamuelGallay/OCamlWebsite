let myWebSockets = Hashtbl.create 10

let send_message m =
  Hashtbl.to_seq_values myWebSockets
  |> List.of_seq
  |> List.map (fun w -> Dream.send w m)
  |> Lwt.join

let rec listen_to nw req =
  match%lwt Dream.receive (Hashtbl.find myWebSockets nw) with
  | Some message ->
    let%lwt () = send_message message in
    let%lwt () = Database.add_comment message req in
    listen_to nw req
  | None ->
    Hashtbl.remove myWebSockets nw;
    Lwt.return ()

let websocket_handler req =
  Dream.websocket (fun websocket ->
      let s = Dream.random 200 in
      Hashtbl.add myWebSockets s websocket;
      listen_to s req)
