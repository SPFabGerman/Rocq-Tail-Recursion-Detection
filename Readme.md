# Rocq Tail Recursion Detection

This Rocq package provides a collection of functions, that allow one to automatically check if a certain function is fully tail recursive (including dependencies) or not.

## Quick Usage Example

```
Require Import Commands.

Fixpoint add (a b : nat) : nat :=
  match a with
    | 0 => b
    | S a => S (add a b)
  end.

MetaCoq Run (ensure_tail_recursion add).
```

The output should be something like:
```
Non-Tail-Recursive Call of add in add (Tests.add): App(Rel(3),[Rel(0),Rel(1)])
Program contains Non-Tail-recursive calls.
```

See also [Tests.v](./examples/Tests.v) for more examples.

## Dependencies

This package depends on [MetaRocq](https://metarocq.github.io/).
Currently supported versions of MetaRocq are: `1.4+9.0`.

## Current Limitations

Mutual Fixpoints are supported.

Currently all fixpoints inside a definition are checked.
But it is not (currently) possible to check nested fixpoints, or lambda functions that are nested inside a fixpoint.

So the following is okay and would be checked:
```
Definition f a :=
  let fix f' a b := ...
  in f' a 0.
```

But the following recursive call would not be checked:
```
Fixpoint f a b :=
  let f' a := f a 0
  in f' a.
```

## Related Projects

The code of this package is somewhat inspired by the OCaml `[@tailcall]` attribute.
(See more [here](https://ocaml.org/manual/5.3/attributes.html).)
Especially the function [`emit_tail_infos`](https://github.com/ocaml/ocaml/blob/b019ca28c88b21545b53d3d82fcf9a43a166768f/lambda/simplif.ml#L622).

## License

Unless otherwise specified, this project is under the [MIT License](https://mit-license.org/).
See also [License](./License).
