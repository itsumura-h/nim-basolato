import tables, strutils, httpcore, times, strformat
import base

proc setDefaultHeaders*(self:HttpHeaders) =
  self["Server"] = &"Nim/{NimVersion}; Basolato/{basolatoVersion}"
  let formatter = initTimeFormat("ddd, dd MMM YYYY HH:mm:ss 'GMT'")
  self["Date"] = now().format(formatter)
  self["Connection"] = "Keep-Alive"

proc `&`*(a, b:HttpHeaders = newHttpHeaders()):HttpHeaders =
  for pair in b.pairs:
    if a.hasKey(pair.key):
      var arr = a.table[pair.key]
      for row in pair.value.split(", "):
        if not arr.contains(row):
          arr.add(row)
      a[pair.key] = arr.join(", ")
    else:
      a[pair.key] = pair.value
  return a
