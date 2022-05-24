module Q = QCheck2

module U = Algaeff.UniqueID.Make (struct type elt = int end)

let compare_id (i1 : U.id) (i2 : U.id) = Int.compare (i1 :> int) (i2 :> int)

let test_uniqueness =
  Q.Test.make ~name:"UniqueID:uniqueness" Q.Gen.(list int)
    (fun l ->
       let ids = U.run @@ fun () -> List.map U.register l in
       List.length (List.sort_uniq compare_id ids) = List.length ids)

let test_retrieve =
  Q.Test.make ~name:"UniqueID:recovery" Q.Gen.(list int)
    (fun l ->
       let ids, exported = U.run @@ fun () ->
         let ids = List.map U.register l in
         let exported = U.export () in
         ids, exported
       in
       let l' = U.run ~init:exported @@ fun () ->
         List.map U.retrieve ids
       in
       l = l')

let () =
  exit @@
  QCheck_base_runner.run_tests ~colors:true ~verbose:true ~long:true
    [ test_uniqueness
    ; test_retrieve
    ]