let post_handler request =
  match%lwt Dream.form request with
  | `Ok [ ("1_login-pseudo", pseudo); ("2_login-password", password) ] ->
      Dream.log "Log in attempt";
      let%lwt b = Database.check_user_password pseudo password request in
      let%lwt () =
        if b then Dream.put_session "user" pseudo request else Lwt.return ()
      in
      Dream.empty ~headers:[ ("Location", "/") ] `See_Other
  | `Ok [ ("1_signup-pseudo", pseudo); ("2_signup-password", password) ] -> (
      Dream.log "Sign up attempt";
      match%lwt Database.check_pseudo pseudo request with
      | false ->
          let%lwt () = Database.add_user pseudo password request in
          Dream.empty ~headers:[ ("Location", "/") ] `See_Other
      | true -> Dream.empty ~headers:[ ("Location", "/") ] `See_Other)
  | `Ok l ->
      let s = l |> List.map fst |> String.concat ", " in
      Dream.log "%s" s;
      Dream.empty ~headers:[ ("Location", "/") ] `See_Other
  | _ ->
      Dream.log "Wrong POST";
      Dream.empty ~headers:[ ("Location", "/") ] `See_Other

let connection_middleware handler request =
  match Dream.session "user" request with
  | Some _username -> handler request (* If  the user is already connected *)
  | None ->
      request
      |> Dream.router
           [
             Dream.post "/" post_handler;
             Dream.get "/" (fun _r -> Dream.respond @@ Rendering.login request);
           ]
         @@ Dream.not_found
