import std/asyncnet
import std/asyncdispatch
import std/httpcore
import std/net
import std/nativesockets
import std/options
import std/strutils
import std/uri
import ../../base
import ../request as basolatoRequest

when defined(httpbeast):
  import httpbeast as backend
else:
  import httpx as backend

export basolatoRequest

type RawRequest* = backend.Request

func rawBody*(request: RawRequest): string =
  if not backend.body(request).isSome():
    raise newException(ErrorHttpParse, "")
  return backend.body(request).get()

func rawHeaders*(request: RawRequest): HttpHeaders =
  if not backend.headers(request).isSome():
    raise newException(ErrorHttpParse, "")
  return backend.headers(request).get()

func rawHttpMethod*(request: RawRequest): HttpMethod =
  if not backend.httpMethod(request).isSome():
    raise newException(ErrorHttpParse, "")
  return backend.httpMethod(request).get()

func rawUrl*(request: RawRequest): Uri =
  if not backend.path(request).isSome():
    raise newException(ErrorHttpParse, "")
  return backend.path(request).get().parseUri()

func rawHostname*(request: RawRequest): string =
  return backend.ip(request)

proc toRequest*(rawRequest: RawRequest): basolatoRequest.Request =
  return basolatoRequest.Request(
    client: newAsyncSocket(AsyncFD(rawRequest.client)),
    reqMethod: rawRequest.rawHttpMethod(),
    headers: rawRequest.rawHeaders(),
    protocol: (orig: "HTTP/1.1", major: 1, minor: 1),
    url: rawRequest.rawUrl(),
    hostname: rawRequest.rawHostname(),
    body: rawRequest.rawBody(),
  )

proc dealKeepAlive*(req: RawRequest) =
  let headers = req.rawHeaders()
  if headers.hasKey("Connection") and (
    headers["Connection"].toLowerAscii() == "close" or
    headers["Connection"].toLowerAscii() != "keep-alive"
  ):
    backend.forget(req)
