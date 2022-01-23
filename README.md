
# obj_viewer
WIP .obj file viewer.

## Build
Requirements:
- [OCaml](https://ocaml.org)
- [Dune](https://dune.build)
- [LablGL](https://github.com/garrigue/lablgl) (`opam install lablgl`)

```
dune build
```

## Usage
```
obj_viewer <path_to_obj>
```

Use left, right, up and down to rotate the model. Use + and - to translate the model along the Z axis.
