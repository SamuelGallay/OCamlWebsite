module type DB = Caqti_lwt.CONNECTION
module R = Caqti_request
module T = Caqti_type

let list_comments =
  let query =
    R.collect T.unit T.(tup2 int string)
      "SELECT id, text FROM comment" in
  fun (module Db : DB) ->
    let%lwt comments_or_error = Db.collect_list query () in
    Caqti_lwt.or_fail comments_or_error

let add_comment =
  let query =
    R.exec T.string
      "INSERT INTO comment (text) VALUES ($1)" in
  fun text (module Db : DB) ->
    let%lwt unit_or_error = Db.exec query text in
    Caqti_lwt.or_fail unit_or_error

let add_user =
  let query =
    R.exec T.(tup2 string string)
      "INSERT INTO users (pseudo, password) VALUES ($1), ($2)" in
  fun pseudo password (module Db : DB) ->
    let%lwt unit_or_error = Db.exec query (pseudo, password) in
    Caqti_lwt.or_fail unit_or_error

let list_user_password = 
  let query =
    R.collect T.(tup2 string string) T.(tup2 string string)
      "SELECT pseudo, password FROM users WHERE pseudo = ($1) AND password = ($2)" in
  fun pseudo password (module Db : DB) ->
    let%lwt up_or_error = Db.collect_list query (pseudo, password) in
    Caqti_lwt.or_fail up_or_error

let check_user_password username passwd request =
  match%lwt Dream.sql (list_user_password username passwd) request with
  | [] -> Lwt.return false
  | _::_ -> Lwt.return true 