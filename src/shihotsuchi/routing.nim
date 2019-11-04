import json
include jester


macro group*(name: untyped, body: untyped): typed =
  # echo treeRepr name
  # echo "----------------"
  # echo treeRepr body
  if name.kind != nnkIdent:
    error("Need an ident.", name)

  routesEx($name.ident, body)
