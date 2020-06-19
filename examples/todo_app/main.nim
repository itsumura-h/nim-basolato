import re
# framework
import ../../src/basolato/routing
# middleware
import app/middlewares/custom_headers_middleware
import app/middlewares/framework_middleware
# controller
# import basolato/welcome_page/controllers/welcome_controller
# import app/controllers/welcome_controller
import app/controllers/todo_controller
import app/controllers/login_controller


router application_router:
  # middleware: hasSessionId
  get "/":
    route(newTodoController(request).index())

routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  get "/login": route(newLoginController(request).index())

  # before re"^(?!\/login).*": hasSessionId
  extend application_router, ""