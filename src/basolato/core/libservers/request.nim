import std/asyncnet
import std/httpcore
import std/strutils
import std/uri

type
  Request* = object
    ## Basolato 共通 Request 型。
    ## asynchttpserver.Request と同じ形状を基準にする。
    client*: AsyncSocket
    reqMethod*: HttpMethod
    headers*: HttpHeaders
    protocol*: tuple[orig: string, major, minor: int]
    url*: Uri
    hostname*: string
    body*: string

func httpMethod*(request: Request): HttpMethod =
  return request.reqMethod

func path*(request: Request): string =
  ## "/aaa/bbb?key=val" => "/aaa/bbb"
  return request.url.path

func url*(request: Request): Uri =
  return request.url

func headers*(request: Request): HttpHeaders =
  return request.headers

func body*(request: Request): string =
  return request.body

func hostname*(request: Request): string =
  return request.hostname

proc dealKeepAlive*(req: Request) =
  if req.client.isNil:
    return

  if (
    req.protocol.major == 1 and
    req.protocol.minor == 1 and
    cmpIgnoreCase(req.headers.getOrDefault("Connection"), "close") == 0
  ) or (
    req.protocol.major == 1 and
    req.protocol.minor == 0 and
    cmpIgnoreCase(req.headers.getOrDefault("Connection"), "keep-alive") != 0
  ):
    req.client.close()
