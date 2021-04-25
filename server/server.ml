let () =
  Dream.run ~https:true ~graceful_stop:false

  @@ Dream.logger
  
  @@ Dream.sql_pool "sqlite3:db.sqlite"
  
  @@ Dream.sql_sessions
  
  @@ Connection.connection_middleware
  
  @@ Dream.router [
    Dream.get "/" (fun r ->
        let%lwt comments = Database.list_comments r in
        Dream.respond @@ Rendering.index r comments);
    
    Dream.post "/" (fun _r -> Dream.empty ~headers:["Location", "/"] `See_Other);
    
    Dream.get "/websocket" Websocket.websocket_handler;
    
    Dream.get "/static/**" (Dream.static "static/");
  ]
  
  @@ Dream.not_found;;
