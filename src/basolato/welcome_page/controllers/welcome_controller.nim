import basolato/controller
# view
import ../resources/welcome

type WelcomeController* = ref object
  request: Request

proc newWelcomeController*(request:Request): WelcomeController =
  return WelcomeController(
    request:request
  )

proc index*(this:WelcomeController):Response =
  let name = "Basolato " & basolatoVersion
  return render(welcomeHtml(name))
