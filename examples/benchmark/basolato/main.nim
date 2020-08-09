# framework
import basolato/routing
# controller
import app/controllers/benchmark_controller

settings:
  port = Port(5000)

routes:
  get "/json": route(newBenchmarkController(request).json())
  get "/plaintext": route(newBenchmarkController(request).plainText())
  get "/db": route(newBenchmarkController(request).db())
  get "/queries": route(newBenchmarkController(request).query())
  get "/fortunes": route(newBenchmarkController(request).fortune())
  get "/updates": route(newBenchmarkController(request).update())
