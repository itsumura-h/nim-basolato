include jester

template response*(body: JsonNode) =
  try:
    resp body
  except:
    let e = getCurrentExceptionMsg()
    resp Http500, e

template response*(body: JsonNode, headersArg: openArray[tuple[key, value: string]]) =
  var headers = headersArg
  headers.add(("Content-Type", "application/json"))
  try:
    resp Http200, headers, $body
  except:
    let e = getCurrentExceptionMsg()
    resp Http500, headers, e

template response*(body: string) =
  try:
    resp body
  except:
    let e = getCurrentExceptionMsg()
    resp Http500, e

template response*(body: string, headers: openArray[tuple[key, value: string]]) =
  try:
    resp Http200, headers, body
  except:
    let e = getCurrentExceptionMsg()
    resp Http500, headers, e
