import std/asyncdispatch
import std/asynchttpserver
import std/json
import std/osproc
import std/strformat
import std/random
import allographer/connection
import allographer/query_builder
  

randomize()

proc threadProc(rdb:Rdb) {.thread.} =
  proc asyncProc() {.async.} =
    var server = newAsyncHttpServer(true, true)
    proc cb(req: Request) {.async, gcsafe.} =
      case req.url.path
      of "/plaintext":
        await req.respond(Http200, "Hello World")
      of "/json":
        await req.respond(Http200, $(%*{"message":"Hello, World!"}))
      of "/db":
        let i = rand(1..10000)
        let response = await rdb.table("World").select("id", "randomNumber").find(i)
        await req.respond(Http200, $(%*response))
      of "/updates":
        let countNum = 100
        var response = newSeq[JsonNode](countNum)
        var getFutures = newSeq[Future[seq[string]]](countNum)
        var updateFutures = newSeq[Future[void]](countNum)
        for i in 1..countNum:
          let index = rand(1..10000)
          let number = rand(1..10000)
          getFutures[i-1] = rdb.table("World").select("id", "randomNumber").findPlain(index)
          updateFutures[i-1] = rdb
                              .table("World")
                              .where("id", "=", index)
                              .update(%*{"randomNumber": number})
          response[i-1] = %*{"id":index, "randomNumber": number}

        try:
          discard await all(getFutures)
          await all(updateFutures)
        except:
          discard

        await req.respond(Http200, $response)
      else:
        await req.respond(Http404, "")

    server.listen(Port(5000))
    while true:
      if server.shouldAcceptRequest():
        await server.acceptRequest(cb)
      else:
        await sleepAsync(500)

  while true:
    try:
      asyncCheck asyncProc()
      runForever()
    except:
      echo repr(getCurrentException())

proc serve() =
  when compileOption("threads"):
    let countThreads = countProcessors()
    var arges = newSeq[Rdb](countThreads)
    for i in 0..arges.len-1:
      arges[i] = dbOpen(PostgreSQL, "database", "user", "pass", "postgreDb", 5432, 50, 30, false, false, "")
    var thr = newSeq[Thread[Rdb]](countThreads)
    for i in 0..countThreads-1:
      createThread(thr[i], threadProc, arges[i])
    echo(&"Starting {countThreads} threads")
    joinThreads(thr)
  else:
    let rdb = dbOpen(PostgreSQL, "database", "user", "pass", "postgreDb", 5432, 200, 30, false, false, "")
    echo(&"Starting 1 thread")
    threadProc(rdb)

serve()
