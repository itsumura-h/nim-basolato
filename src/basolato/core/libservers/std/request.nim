import std/asynchttpserver as asyncHttpServer
import ../request as basolatoRequest

export basolatoRequest

type RawRequest* = asyncHttpServer.Request

func toRequest*(rawRequest: RawRequest): basolatoRequest.Request =
  return basolatoRequest.Request(
    client: rawRequest.client,
    reqMethod: rawRequest.reqMethod,
    headers: rawRequest.headers,
    protocol: rawRequest.protocol,
    url: rawRequest.url,
    hostname: rawRequest.hostname,
    body: rawRequest.body,
  )
