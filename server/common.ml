let getUserName request =

  match Dream.session "user" request with
  | Some username -> username
  | None -> Dream.log "No Username Error"; "World"
