import asyncdispatch, httpcore, re, tables

import ../src/basolato/routing
import ../src/basolato/controller
import ../src/basolato/middleware
# import ../src/basolato/logger

import config/middlewares
from config/custom_headers import corsHeader, middlewareHeader
import app/controllers/sample_controller
import app/controllers/PostsController
import app/controllers/WithHeaderController


router sample:
  get "/checkLogin":
    middleware([checkLogin(request)])
    route(sample_controller.index(), corsHeader())
  get "/fib/@num":
    middleware([check1(), check2()])
    route(sample_controller.fib(@"num"), corsHeader())
  get "/react":
    route(sample_controller.react())
  get "/vue":
    route(sample_controller.vue())
  get "/middlewar_header":
    route(WithHeaderController.middlewar_header(), middlewareHeader())
  get "/header":
    route(WithHeaderController.withHeader())
  get "/middleware":
    route(WithHeaderController.withMiddleware(), middlewareHeader())
  get "/nothing":
    route(WithHeaderController.nothing())
  get "/middlewar_header_json":
    route(WithHeaderController.middlewar_header_json(), middlewareHeader())


router webPagePosts:
  get "":
    route(newPostsController().index())
  get "/@id":
    route(newPostsController().show(@"id"))
  # get "/create":
  #   route(newPostsController().create())
  # post "/create":
  #   route(newPostsController().createConfirm(request))
  # post "":
  #   route(newPostsController().store(request))
  get "/@id/edit":
    route(newPostsController().edit(@"id"))
  post "/@id/edit":
    route(newPostsController().update(@"id", request))
  # get "/@id/delete":
  #   route(newPostsController().destroyConfirm(@"id"))
  # post "/@id/delete":
  #   route(newPostsController().destroy(@"id"))



routes:
  error Http404:
    http404Route

  error Exception:
    exceptionRoute

  options re".*":
    route(render(""), corsHeader())

  # Toppage
  get "/":
    route(sample_controller.index())

  # Sample
  options re"/sample.*":
    middleware([checkLogin(request)])
  extend sample, "/sample"

  # MVCUsers
  extend webPagePosts, "/WebPagePosts"

runForever()

# proc main() =
#   let port = 8000.Port
#   let settings = newSettings(port=port)
#   # var jester = initJester(main_router, settings=settings)
#   var jester = initJester(settings=settings)
#   jester.serve()

# when isMainModule:
#   main()