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

proc set*(this:Headers, key, val:string):Headers =
  var this = this
  this.add((key, val))
  return this

proc set*(this:Headers, key:string, val:openArray[string]):Headers =
  var this = this
  this.add(
    (key, val.join(", "))
  )
  return this
