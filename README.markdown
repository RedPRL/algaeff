# 🦠 Reusable Effects-Based Components

OCaml is bringing algebraic effects to the mainstream, and this library aims to collect reusable effects-based components we have identified.

## Stability

⚠ The API is experimental and unstable. We will break things!

## Components

- [Algaeff.State](https://redprl.org/algaeff/algaeff/Algaeff/State): mutable states
- [Algaeff.Reader](https://redprl.org/algaeff/algaeff/Algaeff/Reader): read-only environments
- [Algaeff.Mutex](https://redprl.org/algaeff/algaeff/Algaeff/Mutex): simple locking to prevent re-entrance
- [Algaeff.Unmonad](https://redprl.org/algaeff/algaeff/Algaeff/Unmonad): effects for any monadic operations

Effect-based concurrency (cooperative lightweight threading) was already tackled by other libraries
such as [Eio](https://github.com/ocaml-multicore/eio) and [Affect](https://erratique.ch/software/affect).
This library focuses on the rest.

There are a few other useful functions and modules:

- [Algaeff.StdlibShim](https://redprl.org/algaeff/algaeff/Algaeff/StdlibShim): a shim for OCaml < 5.
- [Algaeff.Fun.Deep.finally](https://redprl.org/algaeff/algaeff/Algaeff/Fun/Deep/index.html#val-finally): call `continue` or `discontinue` accordingly.
- [Algaeff.Fun.Deep.reperform](https://redprl.org/algaeff/algaeff/Algaeff/Fun/Deep/index.html#val-reperform): continue performing an effect.

## How to Use It

### OCaml >= 5.0.0, OCaml 4.12+domains, or OCaml 4.12+domains+effects

You need a version of OCaml that supports algebraic effects.

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
