import std/asynchttpserver
export asynchttpserver
import std/asyncnet
import std/net
import std/strutils
import std/uri


func path*(request:Request):string =
  ## "/aaa/bbb?key=val" => "/aaa/bbb"
  ## 
  return request.url.path

func httpMethod*(request:Request):HttpMethod =
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
