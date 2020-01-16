import basolato/controller

import ../resources/welcome


proc index*():Response =
  let name = "Basolato " & basolatoVersion
  return render(welcomeHtml(name))
