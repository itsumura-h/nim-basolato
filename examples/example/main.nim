import asyncdispatch, httpcore, re, tables
# framework
import basolato/routing
import basolato/middleware
# middleware
import middlewares/framework_middleware
import middlewares/custom_headers_middleware
import middlewares/check_login_middleware
# controller
import app/controllers/sample_controller

settings:
  port = Port(5000)

router sample:
  get "/welcome": route(newSampleController(request).welcome())
  get "/karax": route(newSampleController(request).karaxIndex())
  get "/fib/@num": route(newSampleController(request).fib(@"num"),
                    [corsHeader()])
  get re"/react.*": route(newSampleController(request).react())
  get "/material-ui": route(newSampleController(request).materialUi())
  get "/vuetify": route(newSampleController(request).vuetify())
  get "/checkLogin":
    middleware([isLogin(request)]);
    route(newSampleController(request).index(), [corsHeader()])
  get "/custom-headers": route(newSampleController(request).customHeaders(),
                          [secureHeader(), corsHeader(), customHeader()])

  get "/cookie": route(newSampleController(request).indexCookie())
  post "/cookie": route(newSampleController(request).storeCookie())
  post "/cookie/update": route(newSampleController(request).updateCookie())
  post "/cookie/delete": route(newSampleController(request).destroyCookie())
  post "/cookie/delete-all": route(newSampleController(request).destroyCookies())

  get "/login": route(newSampleController(request).indexLogin())
  post "/login": route(newSampleController(request).storeLogin())
  post "/logout": route(newSampleController(request).destroyLogin())

  get "/dd": route(newSampleController(request).presentDd())


router api:
  get "/api1":
    route(render("api1"))
  get "/api2":
    route(render("api2"))

# =============================================================================
# router main_router:
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
