import tables, strutils, httpcore, times, strformat
import base


# type Headers* = ref object
#   values: seq[tuple[key: string, val: seq[string]]]


# proc newHeaders*():Headers =
#   return Headers()

# proc hasKey*(headers:Headers, key:string):bool =
#   for header in headers.values:
#     if header.key.toLowerAscii == key:
#       return true
#   return false

# proc getIndex*(headers:Headers, key:string):int =
#   result = -1
#   for i, header in headers.values:
#     if header.key.toLowerAscii == key:
#       return i

# proc add*(self:Headers, key, value:string) =
#   if key.toLowerAscii == "set-cookie":
#     self.values.add((key.toLowerAscii, @[value]))
#   else:
#     let i = self.getIndex(key)
#     if i >= 0:
#       self.values[i].val.add(value)
#     else:
#       self.values.add((key.toLowerAscii, @[value]))

# proc setDefaultHeaders*(self:Headers):Headers =
#   self.add("Server", &"Nim/{NimVersion}; Basolato/{BasolatoVersion}")
#   let formatter = initTimeFormat("ddd, dd MMM YYYY HH:mm:ss 'GMT'")
#   self.add("Date", now().format(formatter))
#   self.add("Connection", "Keep-Alive")

# proc format*(self:Headers):HttpHeaders =
#   var tmpHeader: seq[tuple[key: string, val:string]]
#   for header in self.values:
#     tmpHeader.add((header.key, header.val.join(", ")))
#   return tmpHeader.newHttpHeaders()








func newHttpHeaders*(
  keyValuePairs: openArray[tuple[key: string, val: seq[string]]],
  titleCase=true
): HttpHeaders =
  result = newHttpHeaders(titleCase)
  result.table = newTable[string, seq[string]]()

  for pair in keyValuePairs:
    {.cast(noSideEffect).}:
      if pair.key in result.table:
        # result.table[pair.key] &= pair.val
        result.table[pair.key].add(pair.val)
      else:
        result.table[pair.key] = pair.val

proc setDefaultHeaders*(self:HttpHeaders) =
  self.add("Server", &"Nim/{NimVersion}; Basolato/{BasolatoVersion}")
  let formatter = initTimeFormat("ddd, dd MMM YYYY HH:mm:ss 'GMT'")
  self.add("Date",  now().format(formatter))
  self.add("Connection", "Keep-Alive")

func `==`*(a, b:HttpHeaders):bool =
  return a.table == b.table

func add*(headers: HttpHeaders, key: string, values: openArray[string]) =
  if headers.table.hasKey(key):
    for value in values:
      headers.table[key].add(value)
  else:
    headers.table[key] = @values

proc `&`*(a, b:HttpHeaders = newHttpHeaders()):HttpHeaders =
  for key, values in b.table.pairs:
    if not a.table.hasKey(key):
      a.table[key] = values
    else:
      for value in values:
        if not a.table[key].contains(value):
          a.table[key].add(value)
  return a

proc `&=`*(a, b:HttpHeaders) =
  discard a & b

proc format*(self:HttpHeaders):HttpHeaders =
  var tmp: seq[tuple[key, val:string]]
  for key, values in self.table:
    if key.toLowerAscii == "date":
      tmp.add((key, values[0]))
    elif key.toLowerAscii == "set-cookie":
      for value in values:
        tmp.add((key, value))
    else:
      tmp.add((key, values.join(", ")))
  return tmp.newHttpHeaders(true)

# proc toString*(self:HttpHeaders):string =
#   result = ""
#   for key, values in self.table:
#     if result.len > 0:
#       result.add("\c\L")
#     if key.toLowerAscii == "date": # date should have only one value
#       result.add(key & ": " & values[0])
#     elif key.toLowerAscii == "set-cookie": # each cookie should have own "set-cookie" key
#       for i, value in values:
#         if i > 0:
#           result.add("\c\L")
#         result.add(key & ": " & value)
#     else:
#       result.add(key & ": " & values.join(", "))

proc toString*(headers: HttpHeaders):string =
  result = ""
  for k, v in headers:
    result.add(k & ": " & v & "\c\L")
