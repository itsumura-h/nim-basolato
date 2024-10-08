import std/asyncdispatch
import std/httpcore
import std/json
import std/strformat
import std/times
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/web_socket
# views
import ../views/pages/welcome/welcome_page
import ../views/pages/sample/sample_view
import ../views/pages/with_style/with_style_page
import ../views/pages/babylon_js/babylon_js_page
# import ../views/pages/sample/web_socket_view
import ../views/pages/web_socket/web_socket_page
import ../views/pages/api_view/api_view_page
import ../views/presenters/app_presenter
import ../views/layouts/app/app_layout


proc index*(context:Context):Future[Response] {.async.} =
  const title = "Sample index"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let page = sampleView()
  let view = appLayout(appLayoutModel, page)
  return render(view)


proc welcome*(context:Context):Future[Response] {.async.} =
  let page = welcomePage()
  return render(page)


proc fibLogic(n: int): int =
  if n < 2:
    return n
  return fibLogic(n - 2) + fibLogic(n - 1)


proc fib*(context:Context):Future[Response] {.async.} =
  let num = context.params.getInt("num")
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


proc withStylePage*(context:Context):Future[Response] {.async.} =
  const title = "With Style"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let page = withStylePage()
  let view = appLayout(appLayoutModel, page)
  return render(view)


proc babylonJsPage*(context:Context):Future[Response] {.async.} =
  const title = "Babylon JS"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let page = babylonJsPage()
  let view = appLayout(appLayoutModel, page)
  return render(view)


proc customHeaders*(context:Context):Future[Response] {.async.} =
  var header = newHttpHeaders()
  header.add("Custom-Header-Key1", "Custom-Header-Val1")
  header.add("Custom-Header-Key1", "Custom-Header-Val2")
  header.add("Custom-Header-Key2", ["val1", "val2", "val3"])
  header.add("set-header-test", "aaaa")
  return render("with header", header)


proc presentDd*(context:Context):Future[Response] {.async.} =
  const msg = """
proc customHeaders*(context:Context):Future[Response] {.async.} =
  var header = newHttpHeaders()
  header.add("Custom-Header-Key1", "Custom-Header-Val1")
  header.add("Custom-Header-Key1", "Custom-Header-Val2")
  header.add("Custom-Header-Key2", ["val1", "val2", "val3"])
  header.add("set-header-test", "aaaa")
  return render("with header", header)
"""

  let a = %*{
    "key1": "value1",
    "key2": "value2",
    "key3": "value3",
    "key4": "value4"
  }

  let b = @[1,2,3]

  dd(
    msg,
    a,
    b,
    "abc",
    context.request.repr,
  )
  return render("dd")


proc errorPage*(context:Context):Future[Response] {.async.} =
  let id = context.params.getInt("id")
  if id mod 2 == 1:
    # raise newException(Error400, "Displaying error page")
    return render(Http400, "Displaying error page")
  return render($id)


proc errorRedirect*(context:Context):Future[Response] {.async.} =
  let id = context.params.getInt("id")
  if id mod 2 == 1:
    # raise newException(ErrorRedirect, "/sample/login")
    return errorRedirect("/sample/login")
  return render($id)


proc webSocketIframePage*(context:Context):Future[Response] {.async.} =
  let view = webSocketIframePage()
  return render(view)


proc webSocketPage*(context:Context):Future[Response] {.async.} =
  let view = webSocketPage()
  return render(view)


var connections = newSeq[WebSocket]()


proc webSocket*(context:Context):Future[Response] {.async.} =
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


proc displayApiPage*(context:Context):Future[Response] {.async.} =
  let view = apiViewPage()
  return render(view)
