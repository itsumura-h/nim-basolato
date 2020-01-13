import basolato/controller
import basolato/base

import ../resources/index


proc index*():Response =
  let name = "Basolato " & basolatoVersion
  return render(indexHtml(name))
