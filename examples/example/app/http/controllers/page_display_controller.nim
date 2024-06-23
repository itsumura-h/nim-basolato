import std/asyncdispatch
import std/httpcore
import std/json
import std/strformat
import std/times
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/web_socket
# views
import ../views/pages/welcome_view
import ../views/pages/welcome_scf_view
import ../views/pages/sample/with_style_view
import ../views/pages/sample/babylon_js/babylon_js_view
import ../views/pages/sample/web_socket_view
import ../views/pages/sample/api_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let index = asyncHtml("pages/sample/index.html").await
  return render(index)

proc welcome*(context:Context, params:Params):Future[Response] {.async.} =
  let name = "Basolato " & BasolatoVersion
  return render(welcomeView(name))

proc welcomeScf*(context:Context, params:Params):Future[Response] {.async.} =
  let name = "Basolato " & BasolatoVersion
  return render(welcomeScfView(name).await)

proc fibLogic(n: int): int =
  if n < 2:
    return n
  return fibLogic(n - 2) + fibLogic(n - 1)

proc fib*(context:Context, params:Params):Future[Response] {.async.} =
  let num = params.getInt("num")
  var results: seq[int]
  let startTime = getTime()
  for i in 0..<num:
    results.add(fibLogic(i))
  let endTime = getTime() - startTime # Duration type
  var data = %*{
    "nim": "Nim " & NimVersion,
    "basolato": "Basolato " & BasolatoVersion,
    "time": &"{endTime.inSeconds}.{endTime.inMicroseconds}",
    "fib": results
  }
  return render(data)


proc withStylePage*(context:Context, params:Params):Future[Response] {.async.} =
  let view = withStyleView()
  return render(view)


proc babylonJsPage*(context:Context, params:Params):Future[Response] {.async.} =
  let view = babylonJsView().await
  return render(view)


proc customHeaders*(context:Context, params:Params):Future[Response] {.async.} =
  var header = newHttpHeaders()
  header.add("Custom-Header-Key1", "Custom-Header-Val1")
  header.add("Custom-Header-Key1", "Custom-Header-Val2")
  header.add("Custom-Header-Key2", ["val1", "val2", "val3"])
  header.add("set-header-test", "aaaa")
  return render("with header", header)


proc presentDd*(context:Context, params:Params):Future[Response] {.async.} =
  let a = %*{
    "key1": "value1",
    "key2": "value2",
    "key3": "value3",
    "key4": "value4"
  }
  let b = @[1,2,3]
  dd(
    a,
    b,
    "abc",
    context.request.repr,
  )
  return render("dd")


proc errorPage*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  if id mod 2 == 1:
    # raise newException(Error400, "Displaying error page")
    return render(Http400, "Displaying error page")
  return render($id)

proc errorRedirect*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  if id mod 2 == 1:
    # raise newException(ErrorRedirect, "/sample/login")
    return errorRedirect("/sample/login")
  return render($id)


proc webSocketComponent*(context:Context, params:Params):Future[Response] {.async.} =
  return render(webSocketComponent())

proc webSocketPage*(context:Context, params:Params):Future[Response] {.async.} =
  return render(webSocketView())

var connections = newSeq[WebSocket]()

proc webSocket*(context:Context, params:Params):Future[Response] {.async.} =
  try:
    var ws = newWebSocket(context.request).await
    connections.add(ws)
    await ws.send("Welcome to simple chat server")
    while ws.readyState == Open:
      let packet = ws.receiveStrPacket().await
      echo "Received packet: " & packet
      for other in connections:
        if other.readyState == Open:
          asyncCheck other.send(packet)
  except WebSocketClosedError:
    echo "Socket closed. "
    for connection in connections:
      echo connection.readyState
  except WebSocketProtocolMismatchError:
    echo "Socket tried to use an unknown protocol: ", getCurrentExceptionMsg()
  except WebSocketError:
    echo "Unexpected socket error: ", getCurrentExceptionMsg()
  return render("")

proc displayApiPage*(context:Context, params:Params):Future[Response] {.async.} =
  return render(apiView().await)
