import
  std/asyncdispatch,
  std/httpcore,
  std/net,
  std/options,
  httpbeast


proc onRequest(req:Request):Future[void] {.gcsafe.}=
  if req.path.get() == "/":
    req.send("hello")
  else:
    req.send(Http404)


let settings = initSettings(port=Port(5000))
run(onRequest, settings)
