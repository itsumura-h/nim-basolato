import json, times, strformat
# framework
import ../../../../../src/basolato/controller
import ws
# db
from ../../../database import rdb
import allographer/query_builder
# views
import ../views/pages/welcome_view
import ../views/pages/sample/with_style_view
import ../views/pages/sample/babylon_js/babylon_js_view
import ../views/pages/sample/with_script_view
import ../views/pages/sample/web_socket_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  return render(await asyncHtml("pages/sample/index.html"))

proc welcome*(context:Context, params:Params):Future[Response] {.async.} =
  let name = "Basolato " & BasolatoVersion
  return render(welcomeView(name))

proc fib_logic(n: int): int =
  if n < 2:
    return n
  return fib_logic(n - 2) + fib_logic(n - 1)

proc fib*(context:Context, params:Params):Future[Response] {.async.} =
  let num = params.getInt("num")
  var results: seq[int]
  let start_time = getTime()
  for i in 0..<num:
    results.add(fib_logic(i))
  let end_time = getTime() - start_time # Duration type
  var data = %*{
    "nim": "Nim " & NimVersion,
    "basolato": "Basolato " & BasolatoVersion,
    "time": &"{end_time.inSeconds}.{end_time.inMicroseconds}",
    "fib": results
  }
  return render(data)


proc withStylePage*(context:Context, params:Params):Future[Response] {.async.} =
  return render(withStyleView())


proc babylonJsPage*(context:Context, params:Params):Future[Response] {.async.} =
  return render(babylonJsView().await)

proc withScriptPage*(context:Context, params:Params):Future[Response] {.async.} =
  return render(withScriptView().await)


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
    raise newException(Error400, "Displaying error page")
  return render($id)

proc errorRedirect*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  if id mod 2 == 1:
    raise newException(ErrorRedirect, "/sample/login")
  return render($id)


proc webSocketComponent*(context:Context, params:Params):Future[Response] {.async.} =
  return render(webSocketComponent())

proc webSocketPage*(context:Context, params:Params):Future[Response] {.async.} =
  return render(webSocketView())

var connections = newSeq[WebSocket]()

proc webSocket*(context:Context, params:Params):Future[Response] {.async.} =
  try:
    var ws = await newWebSocket(context.request)
    connections.add(ws)
    await ws.send("Welcome to simple chat server")
    while ws.readyState == Open:
      let packet = await ws.receiveStrPacket()
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
