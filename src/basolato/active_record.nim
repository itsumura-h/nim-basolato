import typetraits, strutils
import allographer/query_builder
export query_builder

type ActiveRecord* = ref object of RootObj

proc newActiveRecord*(this:typedesc, table=""):RDB =
  var table = table
  if table.len == 0:
    table = this.type.name.toLowerAscii & "s"
  return RDB().table(table)
