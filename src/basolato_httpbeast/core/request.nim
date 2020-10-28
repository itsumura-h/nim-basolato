import
  json, strutils, cgi, tables, os, strformat, strtabs,
  parseutils, net, options
import httpbeast


proc isNumeric(str:string):bool =
  result = true
  for c in str:
    if not c.isDigit:
      return false

proc isMatchUrl*(requestPath, routePath:string):bool =
  var requestPath = requestPath.split("?")[0].split("/")[1..^1]
  var routePath = routePath.split("/")[1..^1]
  if requestPath.len != routePath.len:
    return false
  for i in 0..<requestPath.len:
    if not routePath[i].contains("{") and routePath[i] != requestPath[i]:
      return false
    if routePath[i].contains("{"):
      if requestPath[i].len == 0:
        return false
      let typ = routePath[i].replace("{", "").replace("}", "").split(":")[1]
      if typ == "str" and requestPath[i].isNumeric:
        return false
      if typ == "int" and not requestPath[i].isNumeric:
        return false
  return true


proc getUrlParams*(requestPath, routePath:string):JsonNode =
  var urlParams = newJObject()
  if routePath.contains("{"):
    let requestPath = requestPath.split("/")[1..^1]
    let routePath = routePath.split("/")[1..^1]
    for i in 0..<routePath.len:
      if routePath[i].contains("{"):
        let keyInUrl = routePath[i].replace("{", "").replace("}", "").split(":")
        let key = keyInUrl[0]
        let typ = keyInUrl[1]
        if typ == "int":
          urlParams[key] = %requestPath[i].split(":")[0].parseInt
        elif typ == "str":
          urlParams[key] = %requestPath[i].split(":")[0]
  return urlParams


type QueryParams* = TableRef[string, string]

proc newQueryParams():QueryParams =
  return TableRef[string, string]()

proc getQueryParams*(request:Request):QueryParams =
  var params = newQueryParams()
  let query = request.path.get
  for key, val in cgi.decodeData(query):
    params[key] = val
  return params


type RequestParam* = ref object
  fileName*:string
  ext:string
  body:string

type RequestParams* = Table[string, RequestParam]
type MultiData* = OrderedTable[string, tuple[fields: StringTableRef, body: string]]

proc get*(params:RequestParams, key:string, default=""):string =
  if params.hasKey(key):
    return params[key].body
  else:
    return default

proc hasKey*(params:RequestParams, key:string):bool =
  return tables.hasKey(params, key)

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

proc getRequestParams*(request:Request):RequestParams =
  var params = RequestParams()
  if request.headers.get.hasKey("content-type"):
    let contentType = request.headers.get["content-type"].toString
    if contentType.contains("multipart/form-data"):
      let formdata = parseMPFD(contentType, request.body.get)
      for key, row in formdata:
        if row.fields.hasKey("filename"):
          params[key] = RequestParam(
            fileName: row.fields["filename"],
            ext: row.fields["filename"].split(".")[^1],
            body: row.body
          )
        else:
          params[key] = RequestParam(
            body: row.body
          )
    elif contentType.contains("application/x-www-form-urlencoded"):
      let rows = request.body.get.decodeUrl().split("&")
      for row in rows:
        let row = row.split("=")
        params[row[0]] = RequestParam(
          body: row[1]
        )
  return params

proc `[]`*(params:RequestParams, key:string):RequestParam =
  return tables.`[]`(params, key)

proc save*(param:RequestParam, dir:string) =
  ## save file with same file name
  ## .. code-block:: nim
  ##   assert requestParams["upload_file"].filename == "test.jpg"
  ##   requestParams["upload_file"].save("/var/tmp")
  ##   > /var/tmp/test.jpg is stored
  if param.fileName.len > 0:
    var dir = dir
    if dir[0] == '.':
      dir = getCurrentDir() / dir
    createDir(dir)
    var f = open(&"{dir}/{param.fileName}", fmWrite)
    defer: f.close()
    f.write(param.body)

proc save*(param:RequestParam, dir:string, newFileName:string) =
  ## save file with new file name and same extention.
  ## .. code-block:: nim
  ##   assert requestParams["upload_file"].filename == "test.jpg"
  ##   requestParams["upload_file"].save("/var/tmp", "newFileName")
  ##   > /var/tmp/newFileName.jpg is stored
  if param.fileName.len > 0:
    var dir = dir
    if dir[0] == '.':
      dir = getCurrentDir() / dir
    createDir(dir)
    var f = open(&"{dir}/{newFileName}.{param.ext}", fmWrite)
    defer: f.close()
    f.write(param.body)



when isMainModule:
  block:
    let requestPath = "/name/john/id/1"
    let routePath = "/name/{name:str}/id/{id:int}"
    let params = getUrlParams(requestPath, routePath)
    assert params["name"].getStr == "john"
    assert params["id"].getInt == 1

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
