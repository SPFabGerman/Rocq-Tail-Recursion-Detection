# Rocq Tail Recursion Detection

This Rocq package provides a collection of functions, that allow one to automatically check if a certain function is fully tail recursive (including dependencies) or not.

## Dependencies

### Basic Dependencies

This package highly depends on [MetaRocq](https://metarocq.github.io/).

Currently supported versions of MetaRocq are: `1.4+9.0`. However, later versions may work, too.

Other dependencies are:

- GNU make
- OCaml (also a dependency of MetaRocq)

### Evaluation Dependencies

In order to successfully run the evaluation script, additional tools are used:

- sed
- grep
- GNU coreutils (comm, cut, sort, uniq)
- GNU Binutils (objdump)

## Installation

The tool can be installed by first cloning the repository:

> git clone https://github.com/SPFabGerman/Rocq-Tail-Recursion-Detection.git ./rocq-trchecker

Then, after changing into the cloned directory (using `cd rocq-trchecker`), the tool can be
installed using OPAM with

> opam install .

## Evaluation

After cloning the repository, the evaluation can be started by calling

> make evaluation

Alternatively, the evaluation can also be called by directly using the evaluation makefile

> make -f MakefileEval.mk all

Depending on the hardware, the evaluation for parts of the Corelib and Stdlib can take some minutes but usually
should not take more than 10 minutes on reasonable hardware.

The evaluation results are printed both to the console but stored for further inspection in a folder `evaluation_out`.

## Quick Usage Example

```
Require Import Commands.

Fixpoint add (a b : nat) : nat :=
  match a with
    | 0 => b
    | S a => S (add a b)
  end.

MetaRocq Run (check_tail_recursion add true true).
```

The output should be something like:
```
Non-Tail-Recursive Call of add in add (Tests.add): App(Rel(3),[Rel(0),Rel(1)])
Program contains Non-Tail-recursive calls.
```

See also [Tests.v](./examples/Tests.v) for more examples.

## Programs

At the moment we provide two programs:
- `check_tail_recursion FUN SHOW_ALL FAIL_ON_NON_TAILCALLS`
- `check_tail_recursion_in_module MODULE_NAME SHOW_ALL FAIL_ON_NON_TAILCALLS`

`FUN` is the global constant of the function to check.

`MODULE_NAME` is the (full) name of the module, as a string.
(You may need to import `From MetaRocq.Utils Require Import utils.` to get the proper string notation.)

`SHOW_ALL` is a boolean variable.
When `true`, it shows the state of all recursive calls.
When `false`, it only shows problematic (non-tail) recursive calls.

`FAIL_ON_NON_TAILCALLS` is a boolean variable.
When `true`, the program will fail, if a problematic (non-tail) recursive calls is found.
When `false`, the program will never fail.

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
