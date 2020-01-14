import asyncdispatch, httpcore, re, tables

import ../src/basolato/routing
import ../src/basolato/controller
import ../src/basolato/middleware

import middleware/middlewares
from middleware/cors_header_middleware import corsHeader
from middleware/sequre_header_middleware import secureHeader
import middleware/middlewares
import app/controllers/sample_controller
import app/controllers/web_blog_controller


router sample:
  get "/checkLogin":
    middleware([hasLoginId(request), hasLoginToken(request)])
    route(sample_controller.index(), [corsHeader()])
  get "/fib/@num":
    route(sample_controller.fib(@"num"), [corsHeader()])
  get "/react":
    route(sample_controller.react())
  get "/vue":
    route(sample_controller.vue())
  get "/custom_headers":
    route(sample_controller.customHeaders(), [secureHeader(), corsHeader()])

router webBlog:
  get "":
    route(newWebBlogController().index())
  get "/create":
    route(newWebBlogController().create())
  post "/create":
    route(newWebBlogController().store(request))
  get "/@id":
    route(newWebBlogController().show(@"id"))
  # post "":
  #   route(newWebBlogController().store(request))
  get "/@id/edit":
    route(newWebBlogController().edit(@"id"))
  post "/@id/edit":
    route(newWebBlogController().update(@"id", request))
  # get "/@id/delete":
  #   route(newWebBlogController().destroyConfirm(@"id"))
  # post "/@id/delete":
  #   route(newWebBlogController().destroy(@"id"))

router spaBlog:
  get "":
    route(Response())

router api:
  get "/api1":
    route(render("api1"))
  get "/api2":
    route(render("api2"))

# =============================================================================
routes:
  # Framework
  error Http404:
    http404Route
  error Exception:
    exceptionRoute
  before:
    checkCsrfToken(request)
  options re".*":
    route(render(""), [corsHeader()])

# =============================================================================

  # Toppage
  get "/":
    route(sample_controller.index())

  # Sample
  extend sample, "/sample"

  # WebPagePosts
  extend webBlog, "/WebBlog"

  # SpaPosts
  extend spaBlog, "/SpaBlog"

  before re"/api.*":
    middleware([hasLoginId(request), hasLoginToken(request)])
  extend api, "/api"

runForever()

# proc main() =
#   let port = 8000.Port
#   let settings = newSettings(port=port)
#   # var jester = initJester(main_router, settings=settings)
#   var jester = initJester(settings=settings)
#   jester.serve()

# when isMainModule:
#   main()