import tables, strutils, httpcore, times, strformat
import base

func newHttpHeaders*(keyValuePairs:
    openArray[tuple[key: string, val: seq[string]]], titleCase=false): HttpHeaders =
  new result
  result.table = newTable[string, seq[string]]()

  for pair in keyValuePairs:
    {.cast(noSideEffect).}:
      if pair.key in result.table:
        result.table[pair.key] &= pair.val
      else:
        result.table[pair.key] = pair.val

proc setDefaultHeaders*(self:HttpHeaders) =
  self["Server"] = &"Nim/{NimVersion}; Basolato/{basolatoVersion}"
  let formatter = initTimeFormat("ddd, dd MMM YYYY HH:mm:ss 'GMT'")
  self["Date"] = now().format(formatter)
  self["Connection"] = "Keep-Alive"

func add*(headers: HttpHeaders, key: string, values: openArray[string]) =
  if headers.table.hasKey(key):
    for value in values:
      headers.table[key].add(value)
  else:
    headers.table[key] = @values

func `&`*(a, b:HttpHeaders = newHttpHeaders()):HttpHeaders =
  for key, value in b:
    if a.hasKey(key):
      a.add(key, value)
    else:
      a[key] = @[value]
  return a

proc format*(self:HttpHeaders):HttpHeaders =
  let newHeaders = newHttpHeaders()
  for key, values in self:
    if key.toLowerAscii == "date":
      newHeaders[key] = values
      continue
    for value in values.split(", "):
      if newHeaders.hasKey(key):
        let row = newHeaders[key].toString
        if not row.contains(value):
          newHeaders[key] = row & ", " & value
      else:
        newHeaders[key] = value
  return newHeaders
