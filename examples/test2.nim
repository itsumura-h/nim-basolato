import jester, strutils, json

import ../src/shihotsuchi/routing
import controllers/RootController
import config/customHeaders

routes:
  get "/":
    route(RootController.root(request))
  
  post "/":
    route(RootController.rootPost(request))
  
  get "/500":
    route(RootController.root500())

  get "/header":
    route(RootController.root(request), corsHeader(request))

  get "/header500":
    route(RootController.root500(), corsHeader(request))

  get "/json":
    route(RootController.json())

  get "/json500":
    route(RootController.json500())

  get "/jsonHeader":
    route(RootController.json(), corsHeader(request))
  
  get "/json500Header":
    route(RootController.json500(), corsHeader(request))



  # get "/":
  #   route(RootController().root(request))

  # post "/":
  #   route(RootController().rootPost(request))
  
  # get "/500":
  #   route(RootController().root500())

  # get "/header":
  #   route(RootController().root(request), corsHeader(request))

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
