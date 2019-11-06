import asyncdispatch, httpcore, strutils, re, json, sugar, tables

import ../src/shihotsuchi/routing
import ../src/shihotsuchi/controller
import ../src/shihotsuchi/middleware

import config/middlewares
from config/customHeaders import corsHeader
import controllers/ToppageController
import controllers/SampleController
import controllers/ManageUsersController

proc testMiddleware() =
  echo "==================== testMiddlewar ===================="


router toppage:
  get "react/":
    route(ToppageController.react())
  get "vue/":
    route(ToppageController.vue())


router manageUsers:
  get "":
    route(ManageUsersController.index())
  get "create/":
    route(ManageUsersController.create())
  post "":
    route(ManageUsersController.store(request))
  get "@id/":
    route(ManageUsersController.show(@"id"))
  put "@id/":
    route(ManageUsersController.update(@"id"))

router sample:
  get "":
    route(SampleController.index(), corsHeader(request))
  get "checkLogin/":
    middleware([checkLogin(request)])
    route(SampleController.index(), corsHeader(request))
  get "fib/@num/":
    middleware([check1(), check2()])
    route(SampleController.fib(@"num"), corsHeader(request))


routes:
  options re".*":
    route(render(""), corsHeader(request))
  
  # Toppage
  get "/":
    route(ToppageController.index())
  extend toppage, "/toppage/"

  # Sample
  options re"/sample/.*":
    middleware([checkLogin(request)])
  extend sample, "/sample/"
  
  # ManageUsers
  extend manageUsers, "/ManageUsers/"


runForever()

# proc main() =
#   let port = 8000.Port
#   let settings = newSettings(port=port)
#   # var jester = initJester(main_router, settings=settings)
#   var jester = initJester(settings=settings)
#   jester.serve()

# when isMainModule:
#   main()