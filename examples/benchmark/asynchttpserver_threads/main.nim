import random, json
import asynchttpserver, asyncdispatch, osproc
import allographer/query_builder
randomize()

proc serveCore(params:(string, string)) {.thread.} =
  var server = newAsyncHttpServer(true, true)
  proc cb(req: Request) {.async, gcsafe.} =
    var response = newJArray()
    for _ in 1..500:
      let i = rand(1..10000)
      let data = await rdb().table("World").select("id", "randomNumber").asyncFind(i)
      response.add(data)
    await req.respond(Http200, $response)

  waitFor server.serve(Port(5000), cb)

proc serve() =
  let numThreads =
    when compileOption("threads"):
      countProcessors()
    else:
      1
  echo numThreads
  when compileOption("threads"):
    var threads = newSeq[Thread[(string, string)]](numThreads)
    for i in 0 ..< numThreads:
      createThread[(string, string)](
        threads[i], serveCore, ("a", "b")
      )
    joinThreads(threads)
  else:
    serveCore(("a", "b"))

serve()