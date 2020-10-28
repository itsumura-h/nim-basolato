import tables, json, strutils, httpcore, times, strformat
import base


type Headers* = seq[tuple[key, val:string]]

proc newHeaders*(i:int=0): Headers =
  return newSeq[tuple[key, val:string]](i)

proc toHeaders*(headersArg:openArray[tuple]): Headers =
  ## tuple => header
  var headers = newHeaders(headersArg.len)
  for i, row in headersArg:
    headers[i] = (row[0], row[1])
  return headers

proc toHeaders*(headersArg:Table): Headers =
  ## table => header
  var headers = newHeaders(headersArg.len)
  var i = 0
  for key, val in headersArg.pairs:
    headers[i] = (key, val)
    i.inc()
  return headers

proc toHeaders*(headersArg:OrderedTable): Headers =
  ## OrderdTable => header
  var headers = newHeaders(headersArg.len)
  var i = 0
  for key, val in headersArg.pairs:
    headers[i] = (key, val)
    i.inc()
  return headers

proc get(val:JsonNode):string =
  case val.kind
  of JString:
    return val.getStr
  of JInt:
    return $(val.getInt)
  of JFloat:
    return $(val.getFloat)
  of JBool:
    return $(val.getBool)
  of JNull:
    return ""
  else:
    raise newException(JsonKindError, "val is array")

proc toHeaders*(headersArg:JsonNode): Headers =
  ## JsonNode => header
  var headers = newHeaders(headersArg.len)
  var i = 0
  for key, val in headersArg.pairs:
    headers[i] = (key, val.get)
    i.inc()
  return headers

proc hasKey*(this:Headers, key:string):bool =
  result = false
  for header in this:
    if header.key.toLowerAscii() == key.toLowerAscii():
      result = true
      break

proc set*(this:var Headers, key, val:string) =
  this.add((key, val))

proc set*(this:var Headers, key:string, val:openArray[string]) =
  this.add(
    (key, val.join(", "))
  )

proc setDefaultHeaders*(this:var Headers) =
  this.set("Server", &"Nim/{NimVersion}, Basolato/{basolatoVersion}")
  let formatter = initTimeFormat("ddd, dd MMM YYYY HH:mm:ss 'GMT'")
  # this.set("Date", now().format(formatter))
  this.set("Connection", "Keep-Alive")

proc newDefaultHeaders*():Headers =
  var headers = newHeaders()
  headers.setDefaultHeaders()
  return headers

proc toResponse*(this:Headers):string =
  var response = newTable[string, seq[string]](defaultInitialSize)
  result = ""
  for header in this:
    if response.hasKey(header.key):
      response[header.key].add(header.val)
    else:
      response[header.key] = @[header.val]
  let headers = HttpHeaders(table:response)
  var i = 0
  for k, v in headers:
    result.add(k & ": " & v)
    if i < headers.len-1:
      result.add("\c\L")
    i.inc()
