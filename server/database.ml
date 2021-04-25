module type DB = Caqti_lwt.CONNECTION
module R = Caqti_request
module T = Caqti_type

let list_comments request =
  let query =    R.collect T.unit T.(tup2 int string)
  "SELECT id, text FROM comment" in
  let list (module Db : DB) =
    let%lwt comments_or_error = Db.collect_list query () in
    Caqti_lwt.or_fail comments_or_error in
  Dream.sql list request

let add_comment text request =
  let query = R.exec T.string
    "INSERT INTO comment (text) VALUES ($1)" in
  let add (module Db : DB) =
    let%lwt unit_or_error = Db.exec query text in
    Caqti_lwt.or_fail unit_or_error in
  Dream.sql add request

let add_user pseudo password request =
  let query = R.exec T.(tup2 string string)
    "INSERT INTO users (pseudo, password) VALUES ($1, $2)" in
  let add (module Db : DB) =
    let%lwt unit_or_error = Db.exec query (pseudo, password) in
    Caqti_lwt.or_fail unit_or_error in
  Dream.sql add request

let check_pseudo pseudo request =
  let query = R.collect T.string T.string 
    "SELECT pseudo FROM users WHERE pseudo = ($1)" in
  let list_user (module Db : DB) =
    let%lwt up_or_error = Db.collect_list query pseudo in
    Caqti_lwt.or_fail up_or_error in
  match%lwt Dream.sql list_user request with
  | [] -> Lwt.return false
  | _::_ -> Lwt.return true

let check_user_password pseudo password request =
  let query = R.collect T.(tup2 string string) T.(tup2 string string)
    "SELECT pseudo, password FROM users WHERE pseudo = ($1) AND password = ($2)" in
  let list_user_password (module Db : DB) =
    let%lwt up_or_error = Db.collect_list query (pseudo, password) in
    Caqti_lwt.or_fail up_or_error in
  match%lwt Dream.sql list_user_password request with
  | [] -> Lwt.return false
  | _::_ -> Lwt.return true
