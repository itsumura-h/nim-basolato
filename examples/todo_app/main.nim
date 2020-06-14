# framework
import ../../src/basolato/routing
# middleware
import app/middlewares/custom_headers_middleware
import app/middlewares/framework_middleware
# controller
# import basolato/welcome_page/controllers/welcome_controller
# import app/controllers/welcome_controller
import app/controllers/todo_controller

routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  get "/":
    # route(newWelcomeController(request).index(),[corsHeader(), secureHeader()])
    route(newTodoController(request).index())
