import asyncdispatch, httpcore, re, tables

import ../src/basolato/routing
import ../src/basolato/controller
import ../src/basolato/middleware

import middleware/middlewares
from middleware/custom_headers import corsHeader, middlewareHeader
import app/controllers/sample_controller
import app/controllers/web_blog_controller


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

# =============================================================================
routes:
  error Http404:
    http404Route

  error CsrfError:
    resp Http403, getCurrentExceptionMsg()
  before re".*":
    checkCsrfToken(request)

  error Exception:
    exceptionRoute

  options re".*":
    route(render(""), corsHeader())

# =============================================================================

  # Toppage
  get "/":
    route(sample_controller.index())

  # Sample
  options re"/sample.*":
    middleware([checkLogin(request)])
  extend sample, "/sample"

  # WebPagePosts
  extend webBlog, "/WebBlog"

  # SpaPosts
  extend spaBlog, "/SpaBlog"

runForever()

# proc main() =
#   let port = 8000.Port
#   let settings = newSettings(port=port)
#   # var jester = initJester(main_router, settings=settings)
#   var jester = initJester(settings=settings)
#   jester.serve()

# when isMainModule:
#   main()