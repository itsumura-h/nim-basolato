# framework
import ../../../../src/basolato/controller
import ../../../../src/basolato/core/base
# view
import ../../resources/pages/welcome_view


proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let name = "Basolato " & basolatoVersion
  return render(welcomeView(name))
