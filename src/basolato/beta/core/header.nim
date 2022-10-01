import std/tables
import std/strutils
import std/httpcore
import std/times
import std/strformat
import ./base


func toTitleCase(s: string): string =
  result = newString(len(s))
  var upper = true
  for i in 0..len(s) - 1:
    result[i] = if upper: toUpperAscii(s[i]) else: toLowerAscii(s[i])
    upper = s[i] == '-'

# ==================================================

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

func values*(headers: HttpHeaders, key: string):seq[string] =
  if headers.table.hasKey(toTitleCase(key)):
    return headers.table[toTitleCase(key)]
  elif headers.table.hasKey(toLowerAscii(key)):
    return headers.table[toLowerAscii(key)]
  else:
    return newSeq[string]()

proc `&`*(a, b:HttpHeaders = newHttpHeaders(true)):HttpHeaders =
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

proc toString*(headers: HttpHeaders):string =
  result = ""
  for k, v in headers:
    result.add(k & ": " & v & "\c\L")
