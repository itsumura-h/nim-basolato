import typetraits
import allographer/query_builder

type Model* = ref object of RootObj
  db*:RDB
  name*:string

proc newModel*(this:typedesc, table=""):this.type =
  if table.len == 0:
    var table = this.type.name.toLowerAscii & "s"
    return this.type(
      db:RDB().table(table),
      name:table
    )
  else:
    return this.type(
      db:RDB().table(table),
      name:table
    )
