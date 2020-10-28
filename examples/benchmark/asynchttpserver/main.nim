import random, json
import asynchttpserver, asyncdispatch
import allographer/query_builder
randomize()

proc serve(port:int) =
  block:
    var server = newAsyncHttpServer()
    proc cb(req: Request) {.async, gcsafe.} =
      var response = newJArray()
      for _ in 1..500:
        let i = rand(1..10000)
        let data = await rdb().table("World").select("id", "randomNumber").asyncFind(i)
        response.add(data)
      await req.respond(Http200, $response)
    waitFor server.serve(Port(port), cb)


serve(5000)
