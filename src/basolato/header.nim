import tables, json, strutils

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

proc toHeaders*(headersArg:JsonNode): Headers =
  ## JsonNode => header
  var headers = newHeaders(headersArg.len)
  var i = 0
  for key, val in headersArg.pairs:
    headers[i] = (key, val.getStr)
    i.inc()
  return headers

proc hasKey*(this:Headers, key:string):bool =
  var isHeaderHasKey = false
  for header in this:
    if header.key.toLowerAscii() == key.toLowerAscii():
      isHeaderHasKey = true
      break
  return isHeaderHasKey

proc set*(this:var Headers, key, val:string) =
  this.add((key, val))

proc set*(this:var Headers, key:string, val:openArray[string]) =
  this.add(
    (key, val.join(", "))
  )
