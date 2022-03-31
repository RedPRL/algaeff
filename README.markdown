# 🦠 Reusable Effect-Based Components

OCaml is bringing algebraic effects to the mainstream, and this library aims to collect reusable effect-based components we have identified.

## Stability

⚠ The API is experimental and unstable. We will break things if doing so leads to a better design.

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
