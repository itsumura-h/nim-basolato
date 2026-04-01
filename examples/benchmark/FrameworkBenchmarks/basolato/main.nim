import std/os
import std/strutils
# framework
import basolato
# controller
import ./app/http/controllers/benchmark_controller
import ./app/http/controllers/prepared_benchmark_controller

let routes = @[
  Route.get("/plaintext", benchmark_controller.plainText),
  Route.get("/json", benchmark_controller.json),
  Route.get("/db", benchmark_controller.db),
  Route.get("/queries", benchmark_controller.query),
  Route.get("/fortunes", benchmark_controller.fortune),
  Route.get("/updates", benchmark_controller.update),
  Route.get("/cached-queries", benchmark_controller.cachedQuery),

  Route.get("/prepared/plaintext", prepared_benchmark_controller.plainText),
  Route.get("/prepared/json", prepared_benchmark_controller.json),
  Route.get("/prepared/db", prepared_benchmark_controller.db),
  Route.get("/prepared/queries", prepared_benchmark_controller.query),
  Route.get("/prepared/fortunes", prepared_benchmark_controller.fortune),
  Route.get("/prepared/updates", prepared_benchmark_controller.update),
  Route.get("/prepared/cached-queries", prepared_benchmark_controller.cachedQuery),
]

let settings = Settings.new(
  host="0.0.0.0",
  port=8080,
  logToConsole=false,
)

serve(routes, settings)
