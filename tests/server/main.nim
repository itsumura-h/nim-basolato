import asyncdispatch, httpcore, tables
# framework
import ../../src/basolato/routing
# middleware
import app/middlewares/custom_headers_middleware
import app/middlewares/framework_middleware
# controller
import app/controllers/test_controller

settings:
  port = Port(5000)

routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  # test controller
  get "/renderStr": route(newTestController(request).renderStr())
  get "/renderHtml": route(newTestController(request).renderHtml())
  get "/renderTemplate": route(newTestController(request).renderTemplate())
  get "/renderJson": route(newTestController(request).renderJson())
  get "/status500": route(newTestController(request).status500())
  get "/status500json": route(newTestController(request).status500json())
  get "/redirect": route(newTestController(request).redirect())
  get "/error_redirect": route(newTestController(request).error_redirect())

  # test helper
  get "/dd": route(newTestController(request).dd())

  # test response
  get "/set-header": route(newTestController(request).setHeader())
  get "/set-cookie": route(newTestController(request).setCookie())
  get "/set-auth": route(newTestController(request).setAuth())
  get "/destroy-auth": route(newTestController(request).destroyAuth())

  # test routing
  get "/test_routing": route(newTestController(request).getAction())
  post "/test_routing": route(newTestController(request).postAction())
  patch "/test_routing": route(newTestController(request).patchAction())
  put "/test_routing": route(newTestController(request).putAction())
  delete "/test_routing": route(newTestController(request).deleteAction())
