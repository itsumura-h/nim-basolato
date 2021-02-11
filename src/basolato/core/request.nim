import
  asynchttpserver, asyncnet, json, strutils, cgi, tables, os, strformat, strtabs,
  parseutils, net, uri


proc path*(request:Request):string =
  return request.url.path

proc httpMethod*(request:Request):HttpMethod =
  return request.reqMethod

proc dealKeepAlive*(req:Request) =
  if (
    req.protocol.major == 1 and
    req.protocol.minor == 1 and
    cmpIgnoreCase(req.headers.getOrDefault("Connection"), "close") == 0
  ) or
  (
    req.protocol.major == 1 and
    req.protocol.minor == 0 and
    cmpIgnoreCase(req.headers.getOrDefault("Connection"), "keep-alive") != 0
  ):
    req.client.close()

proc isNumeric(str:string):bool =
  result = true
  for c in str:
    if not c.isDigit:
      return false

proc isMatchUrl*(requestPath, routePath:string):bool =
  let requestPath = requestPath.split("/")[1..^1]
  let routePath = routePath.split("/")[1..^1]
  if requestPath.len != routePath.len:
    return false
  for i in 0..<requestPath.len:
    if not routePath[i].contains("{") and routePath[i] != requestPath[i]:
      return false
    if routePath[i].contains("{"):
      if requestPath[i].len == 0:
        return false
      let typ = routePath[i][1..^2].split(":")[1]
      if typ == "str" and requestPath[i].isNumeric:
        return false
      if typ == "int" and not requestPath[i].isNumeric:
        return false
  return true


type Param* = ref object
  fileName*:string
  ext:string
  value:string

type Params* = TableRef[string, Param]


proc `[]`(params:Params, key:string):Param =
  return tables.`[]`(params, key)

proc getStr*(params:Params, key:string, default=""):string =
  if params.hasKey(key):
    return params[key].value
  else:
    return default

proc getInt*(params:Params, key:string, default=0):int =
  if params.hasKey(key):
    return params[key].value.parseInt
  else:
    return default

proc getFloat*(params:Params, key:string, default=0.0):float =
  if params.hasKey(key):
    return params[key].value.parseFloat
  else:
    return default

proc getBool*(params:Params, key:string, default=false):bool =
  if params.hasKey(key):
    return params[key].value.parseBool
  else:
    return default

proc getJson*(params:Params):JsonNode =
  return params["json"].value.parseJson

proc hasKey*(params:Params, key:string):bool =
  return tables.hasKey(params, key)

proc getUrlParams*(requestPath, routePath:string):Params =
  let params = Params()
  if routePath.contains("{"):
    let requestPath = requestPath.split("/")[1..^1]
    let routePath = routePath.split("/")[1..^1]
    for i in 0..<routePath.len:
      if routePath[i].contains("{"):
        let keyInUrl = routePath[i][1..^1].split(":")
        let key = keyInUrl[0]
        params[key] = Param(value:requestPath[i].split(":")[0])
  return params

proc getQueryParams*(request:Request):Params =
  let params = Params()
  let query = request.url.query
  for key, val in cgi.decodeData(query):
    params[key.string] = Param(value:val)
  return params

proc getJsonParams*(request:Request):Params =
  let params = Params()
  let jsonParams = request.body.parseJson
  for k, v in jsonParams.pairs:
    params[k] = Param(value:v.getStr)
  return params


type MultiData* = OrderedTable[string, tuple[fields: StringTableRef, body: string]]

template parseContentDisposition() =
  var hCount = 0
  while hCount < hValue.len()-1:
    var key = ""
    hCount += hValue.parseUntil(key, {';', '='}, hCount)
    if hValue[hCount] == '=':
      var value = hvalue.captureBetween('"', start = hCount)
      hCount += value.len+2
      inc(hCount) # Skip ;
      hCount += hValue.skipWhitespace(hCount)
      if key == "name": name = value
      newPart[0][key] = value
    else:
      inc(hCount)
      hCount += hValue.skipWhitespace(hCount)

proc parseMultiPart*(body: string, boundary: string): MultiData =
  result = initOrderedTable[string, tuple[fields: StringTableRef, body: string]]()
  var mboundary = "--" & boundary

  var i = 0
  var partsLeft = true
  while partsLeft:
    var firstBoundary = body.skip(mboundary, i)
    if firstBoundary == 0:
      raise newException(ValueError, "Expected boundary. Got: " & body.substr(i, i+25))
    i += firstBoundary
    i += body.skipWhitespace(i)

    # Headers
    var newPart: tuple[fields: StringTableRef, body: string] = ({:}.newStringTable, "")
    var name = ""
    while true:
      if body[i] == '\c':
        inc(i, 2) # Skip \c\L
        break
      var hName = ""
      i += body.parseUntil(hName, ':', i)
      if body[i] != ':':
        raise newException(ValueError, "Expected : in headers.")
      inc(i) # Skip :
      i += body.skipWhitespace(i)
      var hValue = ""
      i += body.parseUntil(hValue, {'\c', '\L'}, i)
      if toLowerAscii(hName) == "content-disposition":
        parseContentDisposition()
      newPart[0][hName] = hValue
      i += body.skip("\c\L", i) # Skip *one* \c\L

    # Parse body.
    while true:
      if body[i] == '\c' and body[i+1] == '\L' and
         body.skip(mboundary, i+2) != 0:
        if body.skip("--", i+2+mboundary.len) != 0:
          partsLeft = false
          break
        break
      else:
        newPart[1].add(body[i])
      inc(i)
    i += body.skipWhitespace(i)

    result[name] = newPart

proc parseMPFD*(contentType: string, body: string): MultiData =
  var boundaryEqIndex = contentType.find("boundary=")+9
  var boundary = contentType.substr(boundaryEqIndex, contentType.len()-1)
  return parseMultiPart(body, boundary)

proc getRequestParams*(request:Request):Params =
  var params = Params()
  if request.headers.hasKey("content-type"):
    let contentType = request.headers["content-type"].toString
    if contentType.contains("multipart/form-data"):
      let formdata = parseMPFD(contentType, request.body)
      for key, row in formdata:
        if row.fields.hasKey("filename"):
          params[key] = Param(
            fileName: row.fields["filename"],
            ext: row.fields["filename"].split(".")[^1],
            value: row.body
          )
        else:
          params[key] = Param(
            value: row.body
          )
    elif contentType.contains("application/x-www-form-urlencoded"):
      let rows = request.body.decodeUrl().split("&")
      for row in rows:
        let row = row.split("=")
        params[row[0]] = Param(
          value: row[1]
        )
    elif contentType.contains("application/json"):
      params["json"] = Param(value: request.body)
  return params

proc save*(params:Params, key, dir:string) =
  ## save file with same file name
  ## .. code-block:: nim
  ##   assert params["upload_file"].filename == "test.jpg"
  ##   params.save("upload_file", "/var/tmp")
  ##   > /var/tmp/test.jpg is stored
  let param = params[key]
  if param.fileName.len > 0:
    var dir = dir
    if dir[0] == '.':
      dir = getCurrentDir() / dir
    createDir(dir)
    var f = open(&"{dir}/{param.fileName}", fmWrite)
    defer: f.close()
    f.write(param.value)

proc save*(params:Params, key, dir, newFileName:string) =
  ## save file with new file name and same extention.
  ## .. code-block:: nim
  ##   assert params["upload_file"].filename == "test.jpg"
  ##   params.save("upload_file", "/var/tmp", "newFileName")
  ##   > /var/tmp/newFileName.jpg is stored
  let param = params[key]
  if param.fileName.len > 0:
    var dir = dir
    if dir[0] == '.':
      dir = getCurrentDir() / dir
    createDir(dir)
    var f = open(&"{dir}/{newFileName}.{param.ext}", fmWrite)
    defer: f.close()
    f.write(param.value)



when isMainModule:
  block:
    let requestPath = "/name/john/id/1"
    let routePath = "/name/{name:str}/id/{id:int}"
    let params = getUrlParams(requestPath, routePath)
    assert params.getStr("name") == "john"
    assert params.getInt("id") == 1

  block:
    var requestPath = "/name/john/id/1"
    var routePath = "/name/{name:str}/id/{id:int}"
    assert isMatchUrl(requestPath, routePath) == true

    requestPath = "/name"
    routePath = "/{id:int}"
    assert isMatchUrl(requestPath, routePath) == false

    requestPath = "/1"
    routePath = "/{name:str}"
    assert isMatchUrl(requestPath, routePath) == false

    requestPath = "/1"
    routePath = "/{id:int}"
    assert isMatchUrl(requestPath, routePath) == true

    requestPath = "/john"
    routePath = "/{name:str}"
    assert isMatchUrl(requestPath, routePath) == true

    requestPath = "/"
    routePath = "/{id:int}"
    assert isMatchUrl(requestPath, routePath) == false

    requestPath = "/1/asd"
    routePath = "/{id:int}"
    assert isMatchUrl(requestPath, routePath) == false

    requestPath = "/1/1"
    routePath = "/{id:int}"
    assert isMatchUrl(requestPath, routePath) == false

    requestPath = "/john/1"
    routePath = "/{name:str}"
    assert isMatchUrl(requestPath, routePath) == false
