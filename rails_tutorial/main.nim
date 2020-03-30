# framework
import basolato/routing
# middleware
import middlewares/custom_headers_middleware
import middlewares/framework_middleware
# controller
import app/controllers/application_controller
import app/controllers/static_page_controller

routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  # get "/": route(newApplicationController(request).hello())
  get "/": route(newStaticPageController(request).home())
  get "/static_pages/help": route(newStaticPageController(request).help())
  get "/static_pages/about": route(newStaticPageController(request).about())
  get "/static_pages/contact": route(newStaticPageController(request).contact())

runForever()
