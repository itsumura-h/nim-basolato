import std/asyncdispatch
import std/asynchttpserver
import std/json
import std/osproc
import std/strutils
import std/sequtils
import std/strformat
import std/uri
import std/random
import allographer/connection
import allographer/query_builder
import ../../../../src/basolato/core/benchmark
  

randomize()

proc threadProc(rdb:PostgresConnections) {.thread.} =
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
        let response = rdb.select("id", "randomNumber").table("World").find(i).await
        await req.respond(Http200, $(%*response))
      of "/updates":
        var countNum =
          try:
            (proc():int =
              for row in req.url.query.decodeQuery().toSeq():
                if row.key == "queries":
                  return row.value.parseInt
            )()
          except:
            1
        if countNum < 1:
          countNum = 1
        elif countNum > 500:
          countNum = 500

        let response = newJArray()
        var procs = newSeq[Future[void]](countNum)
        for n in 1..countNum:
          # let i = rand(1..10000)
          let newRandomNumber = rand(1..10000)
          procs[n-1] = (
            proc():Future[void] {.async.} =
              discard rdb.table("World").findPlain(n)
              rdb.table("World").where("id", "=", n).update(%*{"randomNumber": newRandomNumber})
          )()
          response.add(%*{"id":n, "randomNumber": newRandomNumber})
        all(procs).await

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
    var arges = newSeq[PostgresConnections](countThreads)
    for i in 0..arges.len-1:
      arges[i] = dbOpen(PostgreSQL, "database", "user", "pass", "postgreDb", 5432, 458, 30, false, false, "")
    var thr = newSeq[Thread[PostgresConnections]](countThreads)
    for i in 0..countThreads-1:
      createThread(thr[i], threadProc, arges[i])
    echo(&"Starting {countThreads} threads")
    joinThreads(thr)
  else:
    let rdb = dbOpen(PostgreSQL, "database", "user", "pass", "postgreDb", 5432, 200, 30, false, false, "")
    echo(&"Starting 1 thread")
    threadProc(rdb)

serve()
