module Q = QCheck2

module SequencerEff = Algaeff.Sequencer.Make (struct type elt = int end)

type 'a output = Leaf of 'a list | Branch of 'a output * 'a output

let output_to_seq o =
  let rec go o acc =
    match o with
    | Leaf l -> l @ acc
    | Branch (o1, o2) -> go o1 @@ go o2 acc
  in
  List.to_seq @@ go o []

module SequencerMonad =
struct
  type 'a t = 'a * int output
  let ret x : _ t = x, Leaf []
  let bind (m, o1) f : _ t = let x, o2 = f m in x, Branch (o1, o2)
  let yield x = (), Leaf [x]
end

module SequencerUnmonad =
struct
  module U = Algaeff.Unmonad.Make (SequencerMonad)
  type elt = int
  let yield x = U.perform (SequencerMonad.yield x)
  let run f = output_to_seq @@ snd @@ U.run f
end

type cmd = Yield of int
and prog = cmd list

let gen_cmd = Q.Gen.map (fun i -> Yield i) Q.Gen.int
let gen_prog = Q.Gen.list gen_cmd

module SequencerTester (S : Algaeff.Sequencer.S with type elt = int) =
struct
  let trace (prog : prog) =
    let go = function (Yield i) -> S.yield i in
    List.of_seq @@ S.run @@ fun () -> List.iter go prog
end

module SequencerEffTester = SequencerTester (SequencerEff)
module SequencerUnmonadTester = SequencerTester (SequencerUnmonad)

let test_prog =
  Q.Test.make ~name:"Sequencer" gen_prog
    (fun prog ->
       List.equal Int.equal
         (SequencerEffTester.trace prog)
         (SequencerUnmonadTester.trace prog))

let () =
  exit @@
  QCheck_base_runner.run_tests ~colors:true ~verbose:true ~long:true
    [ test_prog ]
