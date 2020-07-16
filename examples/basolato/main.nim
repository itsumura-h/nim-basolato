# framework
import basolato/routing
# middleware
import app/middlewares/custom_headers_middleware
import app/middlewares/framework_middleware
# controller
import app/controllers/welcome_controller
import app/controllers/benchmark_controller

settings:
  port = Port(5000)

routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  get "/": route(newWelcomeController(request).index(),[corsHeader(), secureHeader()])
  get "/plaintext": route(newBenchmarkController(request).plainText())
  get "/json": route(newBenchmarkController(request).jsonAccess())
  get "/db": route(newBenchmarkController(request).dbAccess())
  get "/queries/@queries": route(newBenchmarkController(request).queryAccess(@"queries"))