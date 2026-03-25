import std/asyncdispatch
import std/json
# framework
import basolato/controller
import basolato/core/base
# view
import ../views/pages/welcome/welcome_page


proc welcomePage*(context:Context):Future[Response] {.async.} =
  let page = welcomePageView(context).await
  return render(page)

proc indexApi*(context:Context):Future[Response] {.async.} =
  return render(%*{"message": "Basolato " & BasolatoVersion})
