import std/asyncdispatch
import std/json
# framework
import basolato/controller
import basolato/core/base
# view
import ../views/pages/welcome/welcome_page


proc index*(context:Context):Future[Response] {.async.} =
  let name = "Basolato " & BasolatoVersion
  let page = welcomePage(name)
  return render(page)

proc indexApi*(context:Context):Future[Response] {.async.} =
  return render(%*{"message": "Basolato " & BasolatoVersion})
