import asyncdispatch, httpcore, re, tables

import ../src/basolato/routing
import ../src/basolato/controller
import ../src/basolato/middleware
# import ../src/basolato/logger

import config/middlewares
from config/custom_headers import corsHeader, middlewareHeader
import app/controllers/sample_controller
import app/controllers/web_posts_controller


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
  get "/custom_headers":
    route(sample_controller.customHeaders(), middlewareHeader())


router webPagePosts:
  get "":
    route(newWebPostsController().index())
  get "/@id":
    route(newWebPostsController().show(@"id"))
  # get "/create":
  #   route(newWebPostsController().create())
  # post "/create":
  #   route(newWebPostsController().createConfirm(request))
  # post "":
  #   route(newWebPostsController().store(request))
  get "/@id/edit":
    route(newWebPostsController().edit(@"id"))
  post "/@id/edit":
    route(newWebPostsController().update(@"id", request))
  # get "/@id/delete":
  #   route(newWebPostsController().destroyConfirm(@"id"))
  # post "/@id/delete":
  #   route(newWebPostsController().destroy(@"id"))

router spaPosts:
  get "":
    route(Response())

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

  # WebPagePosts
  extend webPagePosts, "/WebPagePosts"

  # SpaPosts
  extend spaPosts, "/SpaPosts"

runForever()

# proc main() =
#   let port = 8000.Port
#   let settings = newSettings(port=port)
#   # var jester = initJester(main_router, settings=settings)
#   var jester = initJester(settings=settings)
#   jester.serve()

# when isMainModule:
#   main()