# framework
import basolato/routing
# middleware
import middleware/custom_headers_middleware
import middleware/framework_middleware
# controller
import basolato/sample/controllers/sample_controller

routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  get "/":
    route(newSampleController(request).index(),[corsHeader(), secureHeader()])

runForever()
