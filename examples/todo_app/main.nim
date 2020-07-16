# framework
import ../../src/basolato/routing
# middleware
import app/middlewares/custom_headers_middleware
import app/middlewares/framework_middleware
# controller
# import app/controllers/welcome_controller
import app/controllers/login_controller
import app/controllers/todo_controller

settings:
  port = Port(5000)

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

  # todo
  get "/todo": route(newTodoController(request).index())
  post "/todo": route(newTodoController(request).store())
  get "/todo/@id": route(newTodoController(request).show(@"id"))
  post "/todo/@id/delete": route(newTodoController(request).destroy(@"id"))
