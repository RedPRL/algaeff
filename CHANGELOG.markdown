# [2.0.0](https://github.com/RedPRL/algaeff/compare/1.1.0...2.0.0) (2023-10-31)

This major release has two breaking changes:

1. `Algaeff.{Reader,Sequencer,State,UniqueID}` are now taking a module with a type `t`. Previously, the type is named `elt`, `env`, or `state` depending on the component. Now, it is always named `t`. The benefit is that one can write succinct code for built-in types:
   ```ocaml
   module R = Algaeff.Reader.Make (Bool)
   module Sq = Algaeff.Sequencer.Make (Int)
   module St = Algaeff.State.Make (Int)
   module St = Algaeff.UniqueID.Make (String)
   ```
   To upgrade from the older version of this library, please change the type name (`env`, `elt`, or `state`) in
   ```ocaml
   module R = Algaeff.Reader.Make (struct type env = ... end)
   module Sq = Algaeff.Sequencer.Make (struct type elt = ... end)
   module St = Algaeff.State.Make (struct type state = ... end)
   module U = Algaeff.UniqueID.Make (struct type elt = ... end)
   ```
   to `t` as follows:
   ```ocaml
   module R = Algaeff.Reader.Make (struct type t = ... end)
   module Sq = Algaeff.Sequencer.Make (struct type t = ... end)
   module St = Algaeff.State.Make (struct type t = ... end)
   module U = Algaeff.UniqueID.Make (struct type t = ... end)
   ```
2. `Algaeff.Unmonad` is removed.

# [1.1.0](https://github.com/RedPRL/algaeff/compare/1.0.0...1.1.0) (2023-10-01)

### Features

- `{Mutex,Reader,Sequencer,State,UniqueID}.register_printer` to add custom printers for unhandled effects (available in all components except `Unmonad`) ([#19](https://github.com/RedPRL/algaeff/issues/19)) ([2a13145](https://github.com/RedPRL/algaeff/commit/2a13145bca6ef107cb7d80f61c8e34b297d4c723)) ([#22](https://github.com/RedPRL/algaeff/issues/22)) ([9bb4788](https://github.com/RedPRL/algaeff/commit/9bb4788bcab99b3dd40432da87a6de1810c6ad42))
