module AT = Alcotest
module M1 = Eff.Mutex.Make ()
module M2 = Eff.Mutex.Make ()

type cmd = Ret | M1E of prog | M2E of prog | M1R of prog | M2R of prog
and prog = cmd list

let realize (p, r) () =
  let rec go =
    function
    | Ret -> ()
    | M1E p -> M1.exclusively @@ fun () -> go_prog p
    | M2E p -> M2.exclusively @@ fun () -> go_prog p
    | M1R p -> M1.run @@ fun () -> go_prog p
    | M2R p -> M2.run @@ fun () -> go_prog p
  and go_prog p = List.iter go p
  in
  match r with
  | Ok () ->
    Alcotest.(check unit) "no exception" ()
      (go_prog p)
  | Error exn ->
    Alcotest.check_raises "exception" exn
      (fun () -> go_prog p)

let tests = [
  [Ret], Ok ();
  [M1R [M1E [Ret]; M1E [Ret]]], Ok ();
  [M1R [M1E [M1E [Ret]]]], Error M1.Locked;
  [M1R [M2R [M1E [M2E [Ret]]]]], Ok ();
  [M1R [M2R [M2E [M1E [Ret]]]]], Ok ();
  [M1R [M2R [M1E [Ret]; M2E [Ret]]]], Ok ();
]

let () =
  let open Alcotest in
  run "Mutex" [
    "exclusively", List.map (fun t -> test_case "ok" `Quick @@ realize t) tests
  ]
