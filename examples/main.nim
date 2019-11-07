import asyncdispatch, httpcore, strutils, re, json, tables

import ../src/shiotsuchi/routing
import ../src/shiotsuchi/controller
import ../src/shiotsuchi/middleware

import config/middlewares
from config/customHeaders import corsHeader, middlewareHeader
import controllers/ToppageController
import controllers/SampleController
import controllers/ManageUsersController
import controllers/WithHeaderController

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

router withHeaders:
  get "middlewar_header/":
    route(WithHeaderController.middlewar_header(), middlewareHeader())
  get "header/":
    route(WithHeaderController.withHeader())
  get "middleware/":
    route(WithHeaderController.withMiddleware(), middlewareHeader())
  get "nothing/":
    route(WithHeaderController.nothing())
  get "middlewar_header_json/":
    route(WithHeaderController.middlewar_header_json(), middlewareHeader())

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

  # ミドルウェア&ヘッダー
  extend withHeaders, "/withHeader/"


runForever()

# proc main() =
#   let port = 8000.Port
#   let settings = newSettings(port=port)
#   # var jester = initJester(main_router, settings=settings)
#   var jester = initJester(settings=settings)
#   jester.serve()

# when isMainModule:
#   main()