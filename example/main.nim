import asyncdispatch, httpcore, re, tables
# framework
import ../src/basolato/routing
import ../src/basolato/middleware
# middleware
import middleware/framework_middleware
import middleware/custom_headers_middleware
import middleware/check_login_middleware
# controller
import app/controllers/sample_controller


router sample:
  get "/welcome":
    route(newSampleController(request).welcome())
  get "/checkLogin":
    middleware([isLogin(request)])
    route(newSampleController(request).index(), [corsHeader()])
  get "/fib/@num":
    route(newSampleController(request).fib(@"num"), [corsHeader()])
  get "/react":
    route(newSampleController(request).react())
  get "/vue":
    route(newSampleController(request).vue())
  get "/custom_headers":
    route(newSampleController(request).customHeaders(), [secureHeader(), corsHeader(), customHeader()])


router api:
  get "/api1":
    route(render("api1"))
  get "/api2":
    route(render("api2"))

# =============================================================================
routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  # Toppage
  get "/":
    route(newSampleController(request).index())

  # Sample
  extend sample, "/sample"

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
