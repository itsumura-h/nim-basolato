import strutils, json

import ../src/shiotsuchi
import controllers/RootController
import config/customHeaders

routes:
  # get "/":
  #   route(RootController.root(request))
  
  # post "/":
  #   route(RootController.rootPost(request))
  
  # get "/500":
  #   route(RootController.root500())

  # get "/header":
  #   route(RootController.root(request), corsHeader(request))

  # get "/header500":
  #   route(RootController.root500(), corsHeader(request))

  # get "/json":
  #   route(RootController.json())

  # get "/json500":
  #   route(RootController.json500())

  # get "/jsonHeader":
  #   route(RootController.json(), corsHeader(request))
  
  # get "/json500Header":
  #   route(RootController.json500(), corsHeader(request))



  get "/":
    route(RootController().new(request).root())

  # post "/":
  #   route(RootController(request:request).rootPost())
  
  # get "/500":
  #   route(RootController(request:request).root500())

  # get "/header":
  #   route(RootController(request:request).root(), corsHeader(request))

  # get "/header500":
  #   route(RootController(request:request).root500(), corsHeader(request))

  # get "/json":
  #   route(RootController(request:request).json())

  # get "/json500":
  #   route(RootController(request:request).json500())

  # get "/jsonHeader":
  #   route(RootController(request:request).json(), corsHeader(request))
  
  # get "/json500Header":
  #   route(RootController(request:request).json500(), corsHeader(request))
