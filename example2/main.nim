# framework
import basolato/routing
# middleware
import middleware/custom_headers_middleware
import middleware/framework_middleware
# controller
import basolato/sample/controllers/SampleController

routes:
  # Framework
  error Http404:
    http404Route
  error Exception:
    exceptionRoute
  before:
    framework

  get "/":
    route(SampleController.index(), [corsHeader(), secureHeader()])

runForever()
