import basolato/controller

import ../resources/index


proc index*():Response =
  let name = "basolato"
  return render(indexHtml(name))
