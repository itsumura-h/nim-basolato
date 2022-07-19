import options, asyncdispatch
import ../../src/basolato

import ./app/controllers/hello_controller

let ROUTES = @[
  Route.get("/", hello_controller.index)
]

serve(ROUTES)
