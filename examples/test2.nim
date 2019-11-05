import jester, strutils, json

import ../src/shihotsuchi/routing
import controllers/test2Controller
import config/customHeaders

routes:
  # get "/":
  #   route(RootController().root())
  
  # get "/500":
  #   route(RootController().root500())

  # get "/header":
  #   route(RootController().root(), corsHeader(request))

  # get "/header500":
  #   route(RootController().root500(), corsHeader(request))

  # get "/json":
  #   route(RootController().json())

  # get "/json500":
  #   route(RootController().json500())

  # get "/jsonHeader":
  #   route(RootController().json(), corsHeader(request))
  
  # get "/json500Header":
  #   route(RootController().json500(), corsHeader(request))

  get "/":
    route(test2Controller.root())
  
  get "/500":
    route(test2Controller.root500())

  get "/header":
    route(test2Controller.root(), corsHeader(request))

  get "/header500":
    route(test2Controller.root500(), corsHeader(request))

  get "/json":
    route(test2Controller.json())

  get "/json500":
    route(test2Controller.json500())

  get "/jsonHeader":
    route(test2Controller.json(), corsHeader(request))
  
  get "/json500Header":
    route(test2Controller.json500(), corsHeader(request))
