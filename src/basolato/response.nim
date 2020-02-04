import httpcore, json, options, os
# framework
import base
# 3rd party
import httpbeast
from jester import RawHeaders, CallbackAction, ResponseData
import jester/request


template setHeader(headers: var Option[RawHeaders], key, value: string) =
  ## Customized for jester
  bind isNone
  if isNone(headers):
    headers = some(@({key: value}))
  else:
    block outer:
      # Overwrite key if it exists.
      var h = headers.get()
      if key != "Set-cookie": # multiple cookies should be allowed
        for i in 0 ..< h.len:
          if h[i][0] == key:
            h[i][1] = value
            headers = some(h)
            break outer

      # Add key if it doesn't exist.
      headers = some(h & @({key: value}))

template resp*(code: HttpCode,
               headers: openarray[tuple[key, val: string]],
               content: string) =
  ## Sets ``(code, headers, content)`` as the response.
  bind TCActionSend
  result = (TCActionSend, code, none[RawHeaders](), content, true)
  for header in headers:
    setHeader(result[2], header[0], header[1])
  break route


proc header*(response:Response, key:string, value:string):Response =
  var response = response
  var index = 0
  var preValue = ""
  for i, row in response.headers:
    if row.key == key:
      index = i
      preValue = row.val
      break

  if preValue.len == 0:
    response.headers.add(
      (key, value)
    )
  else:
    response.headers[index] = (key, preValue & ", " & value)
  return response

proc header*(response:Response, key:string, valuesArg:openArray[string]):Response =
  var response = response
  var value = ""
  for i, v in valuesArg:
    if i > 0:
      value.add(", ")
    value.add(v)
  response.headers.add((key, value))
  return response

proc response*(arg:ResponseData):Response =
  if not arg[4]: raise newException(Error404, "")
  return Response(
    status: arg[1],
    headers: arg[2].get,
    body: arg[3],
    match: arg[4]
  )
  
proc response*(status:HttpCode, body:string): Response =
  return Response(
    status:status,
    bodyString: body,
    responseType: String
  )

proc html*(r_path:string):string =
  ## arg r_path is relative path from /resources/
  block:
    let path = getCurrentDir() & "/resources/" & r_path
    let f = open(path, fmRead)
    result = $(f.readAll)
    defer: f.close()