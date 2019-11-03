import asyncdispatch, httpcore, strutils, re, json, sugar, tables
import ../src/shihotsuchi
from config/middlewares import middleware
from config/customHeaders import corsHeader
import controllers/ToppageController
import controllers/SampleController
import controllers/ManageUsersController


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
    response(SampleController.index(), corsHeader(request))
  get "fib/@num/":
    response(SampleController.fib(@"num"), corsHeader(request))


routes:
  options re".*":
    response("", corsHeader(request))
  
  # Toppage
  get "/":
    response(ToppageController().index())
  extend toppage, "/toppage/"

  # Sample
  before re"/sample/.*":
    middleware(request)
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