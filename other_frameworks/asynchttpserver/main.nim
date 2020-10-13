import asynchttpserver, asyncdispatch, random, json
import allographer/query_builder
# const
randomize()
const range1_10000 = 1..10000

var server = newAsyncHttpServer()
proc cb(req: Request) {.async, gcsafe.} =
  echo req.repr
  echo req.url.path
  if req.reqMethod == HttpGet:
    case req.url.path:
    of "/db":
      let i = rand(range1_10000)
      let response = rdb().table("world").asyncFind(i)
      await req.respond(Http200, $(await response))
    else:
      await req.respond(Http404, "")

waitFor server.serve(Port(5000), cb)
