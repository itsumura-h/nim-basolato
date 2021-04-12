import json
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/core/base
# view
import ../views/pages/welcome_view


proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let name = "Basolato " & basolatoVersion
  return render(welcomeView(name))

proc indexApi*(request:Request, params:Params):Future[Response] {.async.} =
  let name = "Basolato " & basolatoVersion
  return render(%*{"message": "Basolato " & basolatoVersion})
