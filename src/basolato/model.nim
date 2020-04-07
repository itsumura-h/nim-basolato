import typetraits, strutils
import allographer/query_builder

type Model* = ref object of RootObj
  db*:RDB

proc newModel*(this:typedesc, table=""):this.type =
  var table = table
  if table.len == 0:
    table = this.type.name.toLowerAscii & "s"
  return this.type(
    db:RDB().table(table)
  )
