import os, json, httpcore, strutils

const
  basolatoVersion* = "v0.2.2"
  IS_DISPLAY* = getEnv("LOG_IS_DISPLAY").string.parseBool
  IS_FILE* = getEnv("LOG_IS_FILE").string.parseBool
  LOG_DIR* = getEnv("LOG_DIR").string
  SECRET_KEY* = getEnv("SECRET_KEY").string
  CSRF_TIME* = getEnv("CSRF_TIME").string.parseInt
  SESSION_TIME* = getEnv("SESSION_TIME").string.parseInt
  SESSION_DB_PATH* = getEnv("SESSION_DB_PATH").string
  IS_SESSION_MEMORY* = getEnv("IS_SESSION_MEMORY").string.parseBool

type
  Response* = ref object
    status*:HttpCode
    body*: string
    bodyString*: string
    bodyJson*: JsonNode
    responseType*: ResponseType
    headers*: seq[tuple[key, val:string]]
    url*: string
    match*: bool

  ResponseType* = enum
    String
    Json
    Redirect

  Error505* = object of Exception
  Error504* = object of Exception
  Error503* = object of Exception
  Error502* = object of Exception
  Error501* = object of Exception
  Error500* = object of Exception
  Error451* = object of Exception
  Error431* = object of Exception
  Error429* = object of Exception
  Error428* = object of Exception
  Error426* = object of Exception
  Error422* = object of Exception
  Error421* = object of Exception
  Error418* = object of Exception
  Error417* = object of Exception
  Error416* = object of Exception
  Error415* = object of Exception
  Error414* = object of Exception
  Error413* = object of Exception
  Error412* = object of Exception
  Error411* = object of Exception
  Error410* = object of Exception
  Error409* = object of Exception
  Error408* = object of Exception
  Error407* = object of Exception
  Error406* = object of Exception
  Error405* = object of Exception
  Error404* = object of Exception
  Error403* = object of Exception
  Error401* = object of Exception
  Error400* = object of Exception
  Error307* = object of Exception
  Error305* = object of Exception
  Error304* = object of Exception
  Error303* = object of Exception
  Error302* = object of Exception
  Error301* = object of Exception
  Error300* = object of Exception
  ErrorAuthRedirect* = object of Exception
  DD* = object of Exception

const errorStatusArray* = [505, 504, 503, 502, 501, 500, 451, 431, 429, 428, 426,
  422, 421, 418, 417, 416, 415, 414, 413, 412, 411, 410, 409, 408, 407, 406,
  405, 404, 403, 401, 400, 307, 305, 304, 303, 302, 301, 300]

proc dd*(outputs: varargs[string]) =
  when not defined(release):
    var output:string
    for i, row in outputs:
      if i > 0: output &= "\n\n" else: output &= "\n"
      output.add(row)
    raise newException(DD, output)
