# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/welcome_view


proc index*(context:Context, params:Params):Response =
  let name = "Basolato " & BasolatoVersion
  return render(welcomeView(name))
