import re
# framework
import ../../src/basolato/routing
# middleware
import app/middlewares/custom_headers_middleware
import app/middlewares/framework_middleware
# controller
# import app/controllers/welcome_controller
import app/controllers/login_controller
import app/controllers/todo_controller

routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework


  get "/login": route(newLoginController(request).loginPage())
  post "/login": route(newLoginController(request).login())
  get "/signin": route(newLoginController(request).signinPage())
  post "/signin": route(newLoginController(request).signin())
  get "/logout": route(newLoginController(request).logout())

  get "/": route(newTodoController(request).index())
