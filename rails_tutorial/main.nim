# framework
import basolato/routing
# middleware
import middlewares/custom_headers_middleware
import middlewares/framework_middleware
# controller
import app/controllers/application_controller
import app/controllers/static_page_controller
import app/controllers/users_controller

routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  # get "/": route(newApplicationController(request).hello())
  get "/": route(newStaticPageController(request).home())
  get "/help": route(newStaticPageController(request).help())
  get "/about": route(newStaticPageController(request).about())
  get "/contact": route(newStaticPageController(request).contact())
  get "/signup": route(newUsersController(request).create())

  get "/users/create": route(newUsersController(request).create())
  get "/users/@id": route(newUsersController(request).show(@"id"))
  post "/users": route(newUsersController(request).store())

runForever()
