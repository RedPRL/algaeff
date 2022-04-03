# 🦠 Reusable Effect-Based Components

OCaml is bringing algebraic effects to the mainstream, and this library aims to collect reusable effect-based components we have identified.

## Stability

⚠ The API is experimental and unstable. We will break things if doing so leads to a better design.

## Components

- [Eff.State](https://redprl.org/algaeff/algaeff/Eff/State): mutable states
- [Eff.Reader](https://redprl.org/algaeff/algaeff/Eff/Reader): read-only environments
- [Eff.Mutex](https://redprl.org/algaeff/algaeff/Eff/Mutex): simple locking to prevent re-entrance
- [Eff.Unmonad](https://redprl.org/algaeff/algaeff/Eff/Unmonad): effects for any monadic operations

Effect-based concurrency (cooperative lightweight threading) was already tackled by other libraries
such as [Eio](https://github.com/ocaml-multicore/eio) and [Affect](https://erratique.ch/software/affect).
This library focuses on the rest.

There are a few other useful functions and modules:

- `Eff.StdlibShim`: re-expose `Stdlib.Effect` with name changes introduced in OCaml 5.
- [Eff.Fun.Deep.finally](https://redprl.org/algaeff/algaeff/Eff/Fun/Deep/index.html#val-finally): run an expression, and then call `Effect.Deep.continue` or `Effect.Deep.discontinue` accordingly.
- [Eff.Fun.Deep.reperform](https://redprl.org/algaeff/algaeff/Eff/Fun/Deep/index.html#val-reperform): continue performing an effect.

## How to Use It

### OCaml >= 5.0.0, OCaml 4.12+domains, or OCaml 4.12+domains+effects

You need a version of OCaml that supports algebraic effects.

### Example Code

```ocaml
module S = Eff.State.Make (struct type state = int end)

let forty_two = S.run ~init:100 @@ fun () ->
  print_int (S.get ()); (* this will print out 100 *)
  S.set 42;
  S.get ()
```

### Documentation

[Here is the API documentation.](https://redprl.org/algaeff/algaeff/)
