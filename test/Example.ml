module S = Algaeff.State.Make (Int)

let forty_two = S.run ~init:100 @@ fun () ->
  print_int (S.get ()); (* this will print out 100 *)
  S.set 42;
  S.get ()

let () = assert (forty_two = 42)
