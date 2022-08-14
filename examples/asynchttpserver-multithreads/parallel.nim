import
  std/osproc,
  std/asynchttpserver,
  std/asyncdispatch,
  std/threadpool,
  std/strformat

{.experimental: "parallel".}

proc runHTTPServer() =
  proc listenerHTTP() {.async.} =
    var server = newAsyncHttpServer(true, true)
    proc cb(req: Request) {.async.} =
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

proc serve() =
  when compileOption("threads"):
    let numThreads =  countProcessors()
  else:
    let numThreads = 1

  echo(&"Starting {numThreads} threads")

  if numThreads > 1:
    parallel:
      for i in 1..numThreads:
        spawn runHTTPServer()
  else:
    runHTTPServer()

serve()
