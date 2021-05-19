open Webapi.Dom


let () =
  print_endline "Hello from OCaml ! 4";
  match document |> Document.querySelector("body") with
  | None -> ()
  | Some body ->
    let p = document |> Document.createElement("p") in
    Element.setInnerText p "Helloo";
    Element.appendChild p body