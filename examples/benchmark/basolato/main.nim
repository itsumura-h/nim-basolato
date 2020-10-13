import asyncdispatch
# framework
import ../../../src/basolato/routing
# controller
import app/controllers/benchmark_controller
import app/controllers/async_benchmark_controller

settings:
  port = Port(5000)

routes:
  get "/json": route(newBenchmarkController(request).json())
  get "/plaintext": route(newBenchmarkController(request).plainText())
  get "/db": route(newBenchmarkController(request).db())
  get "/queries": route(newBenchmarkController(request).query())
  get "/fortunes": route(newBenchmarkController(request).fortune())
  get "/updates": route(newBenchmarkController(request).update())

  get "/async/json": route(waitFor newAsyncBenchmarkController(request).json())
  get "/async/plaintext": route(waitFor newAsyncBenchmarkController(request).plainText())
  get "/async/db": route(waitFor newAsyncBenchmarkController(request).db())
  get "/async/queries": route(waitFor newAsyncBenchmarkController(request).query())
  get "/async/fortunes": route(waitFor newAsyncBenchmarkController(request).fortune())
  get "/async/updates": route(waitFor newAsyncBenchmarkController(request).update())
