import asyncdispatch, httpcore, strutils, re, json, sugar, tables
import ../src/shihotsuchi/response
import config/middlewares
from config/customHeaders import corsHeader
import controllers/ToppageController
import controllers/SampleController
import controllers/ManageUsersController

proc testMiddleware() =
  echo "==================== testMiddlewar ===================="


router toppage:
  get "react/":
    response(ToppageController().react())
  get "vue/":
    response(ToppageController().vue())


router manageUsers:
  get "":
    response(ManageUsersController.index())
  get "create/":
    response(ManageUsersController.create())
  post "":
    response(ManageUsersController.store(request))
  get "@id/":
    response(ManageUsersController.show(@"id"))
  put "@id/":
    response(ManageUsersController.update(@"id"))

router sample:
  get "":
    checkLogin(request)
    response(SampleController.index(), corsHeader(request))
  get "fib/@num/":
    checkLogin(request)
    response(SampleController.fib(@"num"), corsHeader(request))


routes:
  options re".*":
    response("", corsHeader(request))
  
  # Toppage
  get "/":
    response(ToppageController().index())
  extend toppage, "/toppage/"

  # Sample
  options re"/sample/.*":
    checkLogin(request)
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