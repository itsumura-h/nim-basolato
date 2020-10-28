import asynchttpserver, asyncdispatch, osproc

proc serveCore(params:(string, string)) {.thread.} =
  var server = newAsyncHttpServer(true, true)
  proc cb(req: Request) {.async, gcsafe.} =
    await req.respond(Http200, "Hello World")

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