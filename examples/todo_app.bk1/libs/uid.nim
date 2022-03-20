import oids, std/sha1

proc genUid*():string =
  return $(secureHash($genOid()))
