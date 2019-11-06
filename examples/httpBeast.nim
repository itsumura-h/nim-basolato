import options, asyncdispatch, strutils, httpbeast

proc onRequest(req: Request): Future[void] =
  echo req.httpMethod
  echo req.path.get()
  if req.httpMethod == some(HttpGet):
    if req.path.get() == "/":
      req.send(Http200, "root")
    if req.path.get() == "/test":
      req.send(Http200, "test")
    if req.path.get().startsWith("/user/"):
      let id = req.path.get()[6 .. ^1]
      req.send(Http200, id)
  if req.httpMethod == some(HttpPost):
    if req.path.get() == "/user":
      req.send(Http200, "")

run(onRequest, Settings(port: Port(5000)))
