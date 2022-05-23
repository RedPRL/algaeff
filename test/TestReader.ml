module Q = QCheck2

module ReaderEff = Algaeff.Reader.Make (struct type env = int end)

module ReaderMonad =
struct
  type 'a t = int -> 'a
  let ret x _ = x
  let bind m f e = f (m e) e
  let read e = e
  let scope f m e = m (f e)
end

module ReaderUnmonad =
struct
  module U = Algaeff.Unmonad.Make (ReaderMonad)
  type env = int
  let read () = U.perform ReaderMonad.read
  let scope f m = U.perform @@ ReaderMonad.scope f @@ U.run m
  let run ~env f = U.run f env
end

type cmd = ReadAndPrint | Scope of (int -> int) * prog
and prog = cmd list

let gen_cmd =
  let open Q.Gen in
  sized @@ fix @@ fun g ->
  function
  | 0 -> pure ReadAndPrint
  | s ->
    frequency
      [ 10, pure ReadAndPrint; (* 10 enables fast testing; 20 would be even faster *)
        1, map2 (fun (Q.Fun (_, f)) p -> Scope (f, p))
          (Q.fun1 Q.Observable.int int)
          (small_list (g (s/2))) (* s/2 enables fast testing; s-1 is too slow *)
      ]

let gen_prog = Q.Gen.list gen_cmd

module ReaderTester (S : Algaeff.Reader.S with type env = int) =
struct
  let trace ~env prog =
    let rec go =
      function
      | ReadAndPrint -> [S.read ()]
      | Scope (f, p) -> S.scope f @@ fun () -> go_prog p
    and go_prog p = List.concat_map go p
    in
    S.run ~env @@ fun () -> go_prog prog
end

module ReaderEffTester = ReaderTester (ReaderEff)
module ReaderUnmonadTester = ReaderTester (ReaderUnmonad)

let test_prog =
  Q.Test.make ~name:"Reader" (Q.Gen.pair Q.Gen.int gen_prog)
    (fun (env, prog) ->
       List.equal Int.equal
         (ReaderEffTester.trace ~env prog)
         (ReaderUnmonadTester.trace ~env prog))

let () =
  exit @@
  QCheck_base_runner.run_tests ~colors:true ~verbose:true ~long:true
    [ test_prog ]
