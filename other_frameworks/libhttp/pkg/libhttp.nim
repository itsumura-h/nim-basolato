import tables, asyncnet, asyncdispatch, parseutils, uri, strutils, options
import httpcore, times
from math import `^`

export httpcore except parseHeader

const maxLineLength = 2 ^ 16
const timeFormatter = initTimeFormat "ddd, dd MMM YYYY HH:mm:ss 'GMT'"

type
  Request* = ref object
    reqMethod*: HttpMethod
    headers*: HttpHeaders
    protocol: HttpVersion
    url*: Uri
    hostname*: string
    body*: string
    initialized: bool

  Response* = ref object
    initialized: bool
    socket: AsyncSocket
    headers*: HttpHeaders
    content: string
    statusCode: HttpCode
    sent: bool

  AsyncHttpServer* = ref object
    port: 1..65535
    host: string
    maxHandlers: int
    reuseAddr: bool
    reusePort: bool
    maxEntitySize: int
    requestPool: seq[Request]
    responsePool: seq[Response]
    socket: AsyncSocket

  RequestLine = tuple
    reqMethod: HttpMethod
    path: Uri
    ver: HttpVersion
  
  RequestHandler = proc (request: Request, response: Response): Future[void] {.closure, gcsafe.}

################# Utility Procs #################
proc `@@`*(this: openArray[(string, seq[string])]): HttpHeaders =
  ## convert key-value pair to HttpHeaders object
  result = new HttpHeaders
  result.table = this.newTable

#################################################

proc createServer*(
  reuseAddr = true,
  reusePort = true,
  address: string = "0.0.0.0",
  port: 1..65535 = 5000,
  maxHandlers = 100, # maximum number of simulataneous requests
  maxSize = 131072 # maximum size of request body
): AsyncHttpServer =
  ## create an AsyncHttpServer
  ## 
  ## Example:
  ## 
  ## .. code-block::nim
  ##    import times
  ##    
  ##    let server = createServer(port=5555, maxHandlers = 10000)
  ##    let formatter = initTimeFormat "ddd, dd MMM YYYY HH:mm:ss 'GMT'"
  ##    
  ##    proc cb(req: Request, res: Response) {.async, gcsafe.} =
  ##      await res
  ##       .status(Http200)
  ##       .header("Content-type", "text/plain; charset=utf-8")
  ##       .header("Date", now().format(formatter))
  ##       .send("Hello World")
  ##    
  ##    proc main =
  ##      var server = createServer()
  ##      asyncCheck server.serve(cb)
  ##      runForever()
  ##    
  ##    main()

  new result
  result.maxHandlers = maxHandlers
  result.port = port
  result.reuseAddr = reuseAddr
  result.reusePort = reusePort
  result.maxEntitySize = maxSize
  result.requestPool = newSeq[Request](maxHandlers)
  result.responsePool = newSeq[Response](maxHandlers)

  for _ in 0..maxHandlers:
    let req = new Request
    req.initialized = false
    req.headers = newHttpHeaders()
    result.requestPool.add req

    let res = new Response
    res.initialized = false
    res.headers = newHttpHeaders()
    result.responsePool.add res

proc newRequest(server: AsyncHttpServer): Request =
  if server.requestPool.len < 1:
    return nil
  result = server.requestPool.pop
  result.initialized = true

proc finalizeRequest(server: AsyncHttpServer, request: Request): void =
  request.initialized = false
  request.headers.clear
  server.requestPool.add request

proc newResponse(server: AsyncHttpServer): Response =
  if server.responsePool.len < 1:
    return nil
  result = server.responsePool.pop
  result.initialized = true

proc finalizeResponse(server: AsyncHttpServer, response: Response): void =
  response.initialized = false
  response.headers.clear
  response.sent = false
  response.socket = nil
  server.responsePool.add response

proc createHeaderFields*(header: HttpHeaders): string =
  result = ""
  for k, v in header:
    result.add(k & ": " & v)
  result.add("\c\L\c\L")

proc status*(response: Response, code: HttpCode): Response {.inline.} =
  result = response
  result.statusCode = code

proc header*(response: Response, key: string, value: string): Response {.inline.} =
  result = response
  result.headers.add(key, value)

proc header*(response: Response, header: HttpHeaders): Response {.inline.} =
  result = response
  for k, v in header:
    result.headers.add(k, v)

proc send*(response: Response, content: string, markAsSent: bool = true): Future[void] {.inline.} =
  if response.sent:
    return newFuture[void]()
  var msg = "HTTP/1.1 " & $response.statusCode & "\c\L"

  if content.len > 0:
    response.headers.add("Content-Length", $content.len)
  response.headers.add("Server", "Nim/" & NimVersion)
  response.headers.add("Date", now().utc.format(timeFormatter))
  msg.add response.headers.createHeaderFields()
  msg.add content
  response.sent = markAsSent
  result = response.socket.send msg

proc respond*(response: Response, code: HttpCode, content: string,
              headers: HttpHeaders = nil): Future[void] =
  result = response
    .status(code)
    .header(headers)
    .send(content)

proc respondError*(response: Response, code: HttpCode): Future[void] =
  let msg = $code
  result = response
    .status(code)
    .send(msg)

proc parseRequestLine(line: string): Option[RequestLine] =
  var parts = line.split ' '

  if parts.len != 3:
    return none(RequestLine)

  var justVal: RequestLine = (HttpGet, initUri(), HttpVer10)

  case parts[0]:
    of "GET": discard
    of "POST":
      justVal.reqMethod = HttpPost
    of "HEAD":
      justVal.reqMethod = HttpHead
    of "PUT":
      justVal.reqMethod = HttpPut
    of "DELETE":
      justVal.reqMethod = HttpDelete
    of "PATCH":
      justVal.reqMethod = HttpPatch
    of "OPTIONS":
      justVal.reqMethod = HttpOptions
    of "CONNECT":
      justVal.reqMethod = HttpConnect
    of "TRACE":
      justVal.reqMethod = HttpTrace
    else:
      return none(RequestLine)

  try:
    parseUri(parts[1], justVal.path)
  except:
    return none(RequestLine)

  case parts[2].toUpper:
    of "HTTP/1.0": discard
    of "HTTP/1.1":
      justVal.ver = HttpVer11
    else:
      return none(RequestLine)

  return some(justVal)

proc processRequest(
  server: AsyncHttpServer,
  req: FutureVar[Request],
  res: FutureVar[Response],
  client: AsyncSocket,
  address: string,
  callback: RequestHandler
): Future[bool] {.async.} =

  template request(): Request = req.mget()

  template response(): Response = res.mget()

  request.headers.clear()
  request.body = ""
  request.hostname.shallowCopy(address)

  response.socket = client

  let lineFut = newFutureVar[string]("server.procesRequest")

  for i in 0..1:
    lineFut.mget.setLen 0
    lineFut.clean()
    if not await client.recvLineInto(lineFut, maxLength=maxLineLength + 1)
                       .withTimeout(10000): # timeout after 10 seconds
      client.close()
      return false

    if lineFut.mget == "":
      client.close()
      return false

    if lineFut.mget.len > maxLineLength:
      await response.respondError(Http413)
      client.close()
      return false

    if lineFut.mget != "\c\L":
      break

  let reqline = parseRequestLine(lineFut.mget)

  if reqline.isNone:
    await response.respondError(Http400)
    return true

  request.protocol = reqline.get.ver
  request.url = reqline.get.path
  request.reqMethod = reqline.get.reqMethod

  var cnt = 0
  while true:
    inc cnt
    lineFut.mget.setLen 0
    lineFut.clean()

    if not await client.recvLineInto(lineFut, maxLength=maxLineLength + 1)
                       .withTimeout(10000): # timeout after 10 seconds
      client.close()
      return false

    if lineFut.mget == "":
      client.close()
      return false

    if lineFut.mget.len > maxLineLength:
      await response.respondError(Http413)
      client.close()
      return false

    if lineFut.mget == "\c\L":
      break

    if cnt > headerLimit:
      await response.respondError(Http400)
      client.close()
      return false

    let (k, v) = parseHeader(lineFut.mget)
    request.headers[k] = v

  if request.reqMethod == HttpPost:
    if request.headers.hasKey("Expect"):
      if "100-continue" in request.headers["Expect"]:
        await response.status(Http100).send("", false)
      else:
        await response.status(Http417).send("", false)

  if request.headers.hasKey("Content-Length"):
    var length = 0

    if request.headers["Content-Length"].parseSaturatedNatural(length) == 0:
      await response
        .status(Http400)
        .send("Bad Request. Invalid Content-Length.")
      return true

    if length > server.maxEntitySize:
      await response.respondError(Http413)
      return false

    request.body = await client.recv(length)

    if request.body.len != length:
      await response
        .status(Http400)
        .send("Bad Request. Content-Length does not match actual.")
      return true

  elif request.reqMethod == HttpPost:
    await response
      .status(Http411)
      .send("Content-Length required.")
    return true

  await callback(request, response)

  if cmpIgnoreCase(request.headers.getOrDefault("Connection"), "upgrade") == 0:
    return false

  if (request.protocol == HttpVer11 and
      cmpIgnoreCase(request.headers.getOrDefault("Connection"), "close") != 0) or
     (request.protocol == HttpVer10 and
      cmpIgnoreCase(request.headers.getOrDefault("Connection"), "keep-alive") == 0):
    return true
  else:
    client.close()
    return false

proc processClient(
  server: AsyncHttpServer,
  client: AsyncSocket,
  address: string,
  req: FutureVar[Request],
  res: FutureVar[Response],
  callback: RequestHandler
) {.async.} =

  try:
    while not client.isClosed:
      let retry = await processRequest(
        server, req, res, client, address, callback
      )
      if not retry: break
  finally:
    server.finalizeRequest(req.mget)
    server.finalizeResponse(res.mget)
    echo $server.requestPool.len

proc temporarilyUnavailable(client: AsyncSocket) {.async.} =
  await client.send("""HTTP/1.1 503 Service Temporarily Unavailable
Content-Type: text/plain; charset=utf-8
Date: $#
Server: Nim/$#
Content-Length: 32
Content-Type: text/plain; charset=utf-8
Service Temporarily Unavailable
""" % [$now().utc.format(timeFormatter), NimVersion])
  client.close()

proc serve*(server: AsyncHttpServer, callback: RequestHandler) {.async.} =
  server.socket = newAsyncSocket()
  if server.reuseAddr:
    server.socket.setSockOpt(OptReuseAddr, true)
  if server.reusePort:
    server.socket.setSockOpt(OptReusePort, true)
  server.socket.bindAddr(Port(server.port), server.host)
  server.socket.listen()

  while true:
    var (address, client) = await server.socket.acceptAddr()

    let request = newFutureVar[Request]()
    request.complete server.newRequest()

    let response = newFutureVar[Response]()
    response.complete server.newResponse()

    if request.mget.isNil or response.mget.isNil:
      asyncCheck client.temporarilyUnavailable
      continue

    asyncCheck processClient(
      server,
      client,
      address,
      request,
      response,
      callback)

proc close*(server: AsyncHttpServer) =
  server.socket.close()
  server.requestPool.setLen(0)
  server.responsePool.setLen(0)

when not defined(testing) and isMainModule:
  proc cb(req: Request, res: Response) {.async, gcsafe.} =
    await res
      .status(Http200)
      .header("Content-type", "text/plain; charset=utf-8")
      .send("Hello World")

  proc main =
    var server = createServer(maxHandlers = 100000)
    asyncCheck server.serve(cb)
    runForever()

  main()