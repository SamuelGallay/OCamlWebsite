open Webapi.Dom

let sprintf = Format.sprintf

type piece = Pawn | Rook | Queen

type color = White | Black

module Board = struct
  type t = (piece * color) option array array

  let size = 8

  let default_board () = Array.make_matrix size size (Some (Pawn, White))

  let print_in grid =
    let tbl = [| "a"; "b"; "c"; "d"; "e"; "f"; "g"; "h" |] in
    for row = size - 1 downto 0 do
      for col = 0 to size - 1 do
        let div = Document.createElement "div" document in
        Element.setInnerText div (sprintf "%s%i" tbl.(col) (row + 1));
        Element.setClassName div
          (if (row + col) mod 2 = 0 then "item-blue" else "item-red");
        Element.appendChild div grid
      done
    done
end

let () =
  print_endline "Hello from OCaml ! 4";

  let body =
    match document |> Document.querySelector "body" with
    | Some b -> b
    | None -> Js.Exn.raiseError "Failed to get body"
  in

  let p = document |> Document.createElement "p" in
  Element.setInnerText p "Helloo";
  Element.appendChild p body;

  let grid = document |> Document.createElement "div" in
  Element.setClassName grid "grid-container";
  Element.appendChild grid body;

  let _bord = Board.default_board () in
  Board.print_in grid
