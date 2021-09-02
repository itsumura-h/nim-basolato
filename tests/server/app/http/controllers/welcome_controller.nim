# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/welcome_view


proc index*(self:WelcomeController):Response =
  let name = "Basolato " & BasolatoVersion
  return render(welcomeView(name))
