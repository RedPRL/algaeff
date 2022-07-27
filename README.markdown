# 🦠 Reusable Effects-Based Components

OCaml is bringing algebraic effects to the mainstream, and this library aims to collect reusable effects-based components we have identified.

## Stability

⚠ The API is experimental and unstable. We will break things!

## Components

- [Algaeff.State](https://redprl.org/algaeff/algaeff/Algaeff/State): mutable states
- [Algaeff.Reader](https://redprl.org/algaeff/algaeff/Algaeff/Reader): read-only environments
- [Algaeff.Sequencer](https://redprl.org/algaeff/algaeff/Algaeff/Sequencer): making a `Seq.t`
- [Algaeff.Mutex](https://redprl.org/algaeff/algaeff/Algaeff/Mutex): simple locking to prevent re-entrance
- [Algaeff.UniqueID](https://redprl.org/algaeff/algaeff/Algaeff/UniqueID): generating unique IDs
- [Algaeff.Unmonad](https://redprl.org/algaeff/algaeff/Algaeff/Unmonad): effects for any monadic operations

Effects-based concurrency (cooperative lightweight threading) was already tackled by other libraries
such as [Eio](https://github.com/ocaml-multicore/eio) and [Affect](https://erratique.ch/software/affect).
This library focuses on the rest.

There are a few other useful functions:

- [Algaeff.Fun.Deep.finally](https://redprl.org/algaeff/algaeff/Algaeff/Fun/Deep/index.html#val-finally): call `continue` or `discontinue` accordingly.
- [Algaeff.Fun.Shallow.finally\_with](https://redprl.org/algaeff/algaeff/Algaeff/Fun/Shallow/index.html#val-finally_with): same as above, but for shallow effect handlers.

## How to Use It

### OCaml >= 5.0.0

You need OCaml 5.

### Example Code

```ocaml
module S = Algaeff.State.Make (struct type state = int end)

let forty_two = S.run ~init:100 @@ fun () ->
  print_int (S.get ()); (* this will print out 100 *)
  S.set 42;
  S.get ()
```

### Documentation

[Here is the API documentation.](https://redprl.org/algaeff/algaeff/Algaeff)
