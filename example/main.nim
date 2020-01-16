import asyncdispatch, httpcore, re, tables
# framework
import ../src/basolato/routing
# import ../src/basolato/controller
import ../src/basolato/middleware
# middleware
import middleware/framework_middleware
import middleware/custom_headers_middleware
import middleware/check_login_middleware
# controller
import app/controllers/sample_controller
import app/controllers/web_blog_controller


router sample:
  get "/welcome":
    route(sample_controller.welcome())
  get "/checkLogin":
    middleware([isLogin(request)])
    route(sample_controller.index(), [corsHeader()])
  get "/fib/@num":
    route(sample_controller.fib(@"num"), [corsHeader()])
  get "/react":
    route(sample_controller.react())
  get "/vue":
    route(sample_controller.vue())
  get "/custom_headers":
    route(sample_controller.customHeaders(), [secureHeader(), corsHeader(), customHeader()])

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
    framework

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
  after re"/api.*":
    route(response(result), [secureHeader(), corsHeader(), customHeader()])
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
