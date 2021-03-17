# framework
import basolato/controller
# view
import ../views/pages/welcome_view


proc index*(self:WelcomeController):Response =
  let name = "Basolato " & basolatoVersion
  return render(welcomeView(name))
