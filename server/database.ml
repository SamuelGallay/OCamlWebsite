let query_packing a req =
  let f m =
    match%lwt a m with
    | Ok a -> Lwt.return a
    | Error _e ->
        failwith "Database, SQL or I don't know what error... I am sorry"
  in
  Dream.sql req f

let ( |>= ) g f x = Lwt.map f (g x)

let list_comments =
  [%rapper get_many {sql| SELECT @int{id}, @string{text} FROM comment |sql}] ()
  |> query_packing

let add_comment text =
  [%rapper
    execute {sql| INSERT INTO comment (text) VALUES (%string{text}) |sql}]
    ~text
  |> query_packing

let add_user pseudo password =
  [%rapper
    execute
      {sql| INSERT INTO users VALUES (%string{pseudo}, %string{password}) |sql}]
    ~pseudo ~password
  |> query_packing

let check_pseudo pseudo =
  [%rapper
    get_opt
      {sql| SELECT @string{pseudo} FROM users WHERE pseudo = %string{pseudo} |sql}]
    ~pseudo
  |> query_packing |>= Option.is_some

let check_user_password pseudo password =
  [%rapper
    get_opt
      {sql| SELECT @string{pseudo}, @string{password} FROM users WHERE pseudo = %string{pseudo} AND password = %string{password} |sql}]
    ~pseudo ~password
  |> query_packing |>= Option.is_some

