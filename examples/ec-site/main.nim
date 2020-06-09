# framework
import ../../src/basolato/routing
# middleware
import middlewares/custom_headers_middleware
import middlewares/framework_middleware
# controller
import ../../src/basolato/welcome_page/controllers/welcome_controller

routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  get "/":
    route(newWelcomeController(request).index(),[corsHeader(), secureHeader()])
