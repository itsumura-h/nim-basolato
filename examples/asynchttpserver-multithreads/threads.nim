import
  std/osproc,
  std/asynchttpserver,
  std/asyncdispatch,
  std/strformat


proc runHTTPServer() {.thread.} =
  proc listenerHTTP() {.async.} =
    var server = newAsyncHttpServer(true, true)
    proc cb(req: Request) {.async, gcsafe.} =
      let headers = {"Content-type": "text/plain; charset=utf-8"}
      await req.respond(Http200, "Hello World", headers.newHttpHeaders())

    server.listen(Port(5000))
    while true:
      if server.shouldAcceptRequest():
        await server.acceptRequest(cb)
      else:
        await sleepAsync(500)

  while true:
    try:
      asyncCheck listenerHTTP()
      runForever()
    except:
      echo repr(getCurrentException())

proc serve() =
  when compileOption("threads"):
    let numThreads = countProcessors()
  else:
    let numThreads = 1

  echo(&"Starting {numThreads} threads")

  if numThreads > 1:
    when compileOption("threads"):
      var thr = newSeq[Thread[void]](numThreads)
      for i in 1..numThreads:
        createThread(thr[i-1], runHTTPServer)
      joinThreads(thr)
  else:
    runHTTPServer()

serve()