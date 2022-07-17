import asynchttpserver, asyncdispatch, osproc, random, json, net, selectors, nativesockets, times, os, options
import allographer/query_builder
randomize()
const range1_10000 = 1..10000

proc createResponse():string =
  return "Hello World"

type
  Cd = proc(req: Request)

proc cb(req: Request) {.async, gcsafe, thread.} =
  case req.url.path
  of "/plaintext":
    await req.respond(Http200, "Hello World")
  of "/plaintext/method":
    let respose = createResponse()
    await req.respond(Http200, respose)
  of "/db":
    let i = rand(1..10000)
    var response:Option[JsonNode]
    when getEnv("DB_DRIVER") == "mysql":
      response = rdb().table("World").select("id", "randomNumber").find(i)
    else:
      response = await rdb().table("World").select("id", "randomNumber").asyncFind(i)
    await req.respond(Http200, $(%*response))
  of "/updates":
    var countNum = 500

    var response = newSeq[JsonNode](countNum)

    when getEnv("DB_DRIVER") == "mysql":
      for i in 1..countNum:
        let index = rand(range1_10000)
        let number = rand(range1_10000)
        discard rdb().table("World").select("id", "randomNumber").findPlain(index)
        rdb()
          .table("World")
          .where("id", "=", index)
          .update(%*{"randomNumber": number})
        response[i-1] = %*{"id":index, "randomNumber": number}
    else:
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

proc serveCore(port:int) {.thread.} =
  var server = newAsyncHttpServer(true, true)
  waitFor server.serve(Port(port), cb)

proc serve(port:int) =
  let numThreads =
    when compileOption("threads"):
      countProcessors()
    else:
      1
  echo numThreads
  when compileOption("threads"):
    var threads = newSeq[Thread[int]](numThreads)
    for i in 0 ..< numThreads:
      createThread[int](
        threads[i], serveCore, port
      )
    joinThreads(threads)
  else:
    serveCore(port)

serve(5000)