import asynchttpserver, asyncdispatch, osproc, random, json
import allographer/query_builder
randomize()
const range1_10000 = 1..10000

proc serveCore(params:(string, string)) {.thread.} =
  var server = newAsyncHttpServer(true, true)

  proc createResponse():string =
    return "Hello World"

  proc cb(req: Request) {.async, gcsafe.} =
    case req.url.path
    of "/plaintext":
      await req.respond(Http200, "Hello World")
    of "/plaintext/method":
      let respose = createResponse()
      await req.respond(Http200, respose)
    of "/updates":
      var countNum = 500

      var response = newSeq[JsonNode](countNum)
      var getFutures = newSeq[Future[Row]](countNum)
      var updateFutures = newSeq[Future[void]](countNum)
      for i in 1..countNum:
        let index = rand(range1_10000)
        let number = rand(range1_10000)
        getFutures[i-1] = rdb().table("World").select("id", "randomNumber").asyncFindPlain(index)
        updateFutures[i-1] = rdb()
                            .table("World")
                            .where("id", "=", index)
                            .asyncUpdate(%*{"randomNumber": number})
        response[i-1] = %*{"id":index, "randomNumber": number}

      try:
        discard await all(getFutures)
        await all(updateFutures)
      except:
        discard
      await req.respond(Http200, $response)
    else:
      await req.respond(Http404, "")

  waitFor server.serve(Port(5000), cb)

proc serve() =
  let numThreads =
    when compileOption("threads"):
      countProcessors()
    else:
      1
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