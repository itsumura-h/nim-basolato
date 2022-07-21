import
  std/osproc,
  std/asynchttpserver,
  std/asyncdispatch


proc runHTTPServer() {.thread.} =
  proc listenerHTTP() {.async.} =
    var server = newAsyncHttpServer(true, true)
    proc cb(req: Request) {.async, gcsafe.} =
      # echo (req.reqMethod, req.url, req.headers)
      let headers = {"Content-type": "text/plain; charset=utf-8"}
      await req.respond(Http200, "Hello World", headers.newHttpHeaders())

    server.listen(Port(5000)) # or Port(8080) to hardcode the standard HTTP port.
    let port = server.getPort
    echo "test this with: curl localhost:" & $port.uint16 & "/"
    while true:
      if server.shouldAcceptRequest():
        await server.acceptRequest(cb)
      else:
        # too many concurrent connections, `maxFDs` exceeded
        # wait 500ms for FDs to be closed
        await sleepAsync(500)
  
  while true:
    try:
      asyncCheck listenerHTTP()
      runForever()
    except:
      echo repr(getCurrentException())

proc main() =
  when compileOption("threads"):
    let numThreads =  countProcessors()
  else:
    let numThreads = 1

  if numThreads > 1:
    when compileOption("threads"):
      var thr = newSeq[Thread[void]](numThreads)
      for i in 1..numThreads:
        createThread(thr[i-1], runHTTPServer)
      joinThreads(thr)
  else:
    runHTTPServer()

main()