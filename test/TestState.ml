module Q = QCheck2

module StateEff = Algaeff.State.Make (struct type state = int end)

module StateMonad =
struct
  type 'a t = int -> 'a * int
  let ret x s = x, s
  let bind m f s = let x, s = m s in f x s
  let get s = s, s
  let set s _ = (), s
  let modify f s = (), f s
end

module StateUnmonad =
struct
  module U = Algaeff.Unmonad.Make (StateMonad)
  type state = int
  let get () = U.perform StateMonad.get
  let set s = U.perform @@ StateMonad.set s
  let modify f = U.perform @@ StateMonad.modify f
  let run ~init f = fst @@ U.run f init
end

type cmd = Set of int | GetAndPrint | Mod of (int -> int)

let gen_cmd =
  let open Q.Gen in
  oneof
    [map (fun i -> Set i) int;
     pure GetAndPrint;
     map (fun (Q.Fun (_, f)) -> Mod f) (Q.fun1 Q.Observable.int int)]

let gen_prog = Q.Gen.list gen_cmd

module StateTester (S : Algaeff.State.S with type state = int) =
struct
  let trace ~init prog =
    let go =
      function
      | Set i -> S.set i; []
      | GetAndPrint -> [S.get ()]
      | Mod f -> S.modify f; []
    in
    S.run ~init @@ fun () -> List.concat_map go prog
end

module StateEffTester = StateTester (StateEff)
module StateUnmonadTester = StateTester (StateUnmonad)

let test_prog =
  Q.Test.make ~name:"equal" (Q.Gen.pair Q.Gen.int gen_prog)
    (fun (init, prog) ->
       List.equal Int.equal
         (StateEffTester.trace ~init prog)
         (StateUnmonadTester.trace ~init prog))

let () =
  exit @@
  QCheck_base_runner.run_tests ~colors:true ~verbose:true ~long:true
    [ test_prog ]
