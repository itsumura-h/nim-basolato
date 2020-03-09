# framework
import basolato/routing
# middleware
import middleware/custom_headers_middleware
import middleware/framework_middleware
# controller
import basolato/welcome_page/controllers/welcome_controller

routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  get "/":
    route(newWelcomeController(request).index(),[corsHeader(), secureHeader()])

runForever()
