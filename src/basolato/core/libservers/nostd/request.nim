import std/cgi
import std/httpcore
import std/json
import std/net
import std/nativesockets
import std/options
import std/os
import std/parseutils
import std/strformat
import std/strtabs
import std/strutils
import std/tables
import std/uri
import ../../base

when defined(httpbeast):
  from httpbeast import Request; export Request
  from httpbeast import body
  from httpbeast import headers
  from httpbeast import httpMethod
  from httpbeast import path
  from httpbeast import ip
  from httpbeast import forget
else:
  from httpx as httpbeast import Request; export Request
  from httpx as httpbeast import body
  from httpx as httpbeast import headers
  from httpx as httpbeast import httpMethod
  from httpx as httpbeast import path
  from httpx as httpbeast import ip
  from httpx as httpbeast import forget


func body*(request:Request):string =
  if not httpbeast.body(request).isSome():
    raise newException(ErrorHttpParse, "")
  return httpbeast.body(request).get()

func headers*(request:Request):HttpHeaders =
  if not httpbeast.headers(request).isSome():
    raise newException(ErrorHttpParse, "")
  return httpbeast.headers(request).get()

func httpMethod*(request:Request):HttpMethod =
  if not httpbeast.httpMethod(request).isSome():
    raise newException(ErrorHttpParse, "")
  return httpbeast.httpMethod(request).get()

func url*(request:Request):Uri =
  if not httpbeast.path(request).isSome():
    raise newException(ErrorHttpParse, "")
  return httpbeast.path(request).get().parseUri()

func path*(request:Request):string =
  return request.url.path

func hostname*(request:Request):string =
  return httpbeast.ip(request)


proc dealKeepAlive*(req:Request) =
  if req.headers.hasKey("Connection") and
  (
    req.headers["Connection"].toLowerAscii() == "close" or
    req.headers["Connection"].toLowerAscii() != "keep-alive"
  ):
    req.forget()

func isNumeric(str:string):bool =
  result = true
  for c in str:
    if not c.isDigit:
      return false

func isMatchUrl*(requestPath, routePath:string):bool =
  let requestPath = requestPath.split("?")[0].split("/")[1..^1]
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

func `$`*(self:Param):string =
  return self.value

func ext*(self:Param):string =
  return self.ext

func len*(self:Param):int =
  return self.value.len

type Params* = TableRef[string, Param]

proc new*(_:type Params):Params =
  return newTable[string, Param]()


func `[]`*(params:Params, key:string):Param =
  return tables.`[]`(params, key)

func `[]=`*(params:Params, key:string, value:Param) =
  tables.`[]=`(params, key, value)

func getStr*(params:Params, key:string, default=""):string =
  if params.hasKey(key):
    return params[key].value
  else:
    return default

func getInt*(params:Params, key:string, default=0):int =
  try:
    return params[key].value.parseInt
  except:
    return default

func getFloat*(params:Params, key:string, default=0.0):float =
  try:
    return params[key].value.parseFloat
  except:
    return default

func getBool*(params:Params, key:string, default=false):bool =
  try:
    return params[key].value.parseBool
  except:
    return default

proc getJson*(params:Params, key:string, default=newJObject()):JsonNode =
  try:
    return params[key].value.parseJson
  except:
    return default

proc getAll*(params:Params):JsonNode =
  result = newJObject()
  for key, param in params:
    let ext = param.ext
    let fileName = param.fileName
    let value =
      if ext.len > 0:
        ""
      else:
        param.value
    result[key] = %*{"ext": ext, "fileName": fileName, "value": value}

func getUrlParams*(requestPath, routePath:string):Params =
  result = Params.new()
  if routePath.contains("{"):
    let requestPath = requestPath.split("/")[1..^1]
    let routePath = routePath.split("/")[1..^1]
    for i in 0..<routePath.len:
      if routePath[i].contains("{"):
        let keyInUrl = routePath[i][1..^1].split(":")
        let key = keyInUrl[0]
        result[key] = Param(value:requestPath[i].split(":")[0])

func getQueryParams*(request:Request):Params =
  result = Params.new()
  let query = request.url.query
  for key, val in cgi.decodeData(query):
    result[key] = Param(value:val)

proc getJsonParams*(request:Request):Params =
  result = Params.new()
  let jsonParams = request.body.parseJson()
  for k, v in jsonParams.pairs:
    case v.kind
    of JInt:
      result[k] = Param(value: $(v.getInt))
    of JFloat:
      result[k] = Param(value: $(v.getFloat))
    of JBool:
      result[k] = Param(value: $(v.getBool))
    of JNull:
      result[k] = Param(value: "")
    of JArray:
      result[k] = Param(value: $v)
    of JObject:
      result[k] = Param(value: $v)
    else:
      result[k] = Param(value: v.getStr)

proc `%`*(self:Params):JsonNode =
  var data = newJObject()
  for key, param in self:
    if param.ext.len == 0:
      data[key] = %param.value
  return data

type MultiData = OrderedTable[string, tuple[fields: StringTableRef, body: string]]

# template parseContentDisposition() =
#   var hCount = 0
#   while hCount < hValue.len()-1:
#     var key = ""
#     hCount += hValue.parseUntil(key, {';', '='}, hCount)
#     if hValue[hCount] == '=':
#       var value = hvalue.captureBetween('"', start = hCount)
#       hCount += value.len+2
#       inc(hCount) # Skip ;
#       hCount += hValue.skipWhitespace(hCount)
#       if key == "name": name = value
#       newPart[0][key] = value
#     else:
#       inc(hCount)
#       hCount += hValue.skipWhitespace(hCount)

func parseMultiPart(body: string, boundary: string): MultiData =
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
        # parseContentDisposition()
        block:
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

func parseMPFD(contentType: string, body: string): MultiData =
  var boundaryEqIndex = contentType.find("boundary=")+9
  var boundary = contentType.substr(boundaryEqIndex, contentType.len()-1)
  return parseMultiPart(body, boundary)

proc getRequestParams*(request:Request):Params =
  let params = Params.new()
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
          if params.hasKey(key):
            params[key].value.add(", " & row.body)
          else:
            params[key] = Param(value: row.body)
    elif contentType.contains("application/x-www-form-urlencoded"):
      let body = request.body.decodeUrl()
      if body.len > 0:
        let rows = body.split("&")
        for row in rows:
          let row = row.split("=")
          if params.hasKey(row[0]):
            params[row[0]].value.add(", " & row[1])
          else:
            params[row[0]] = Param(value: row[1])
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
