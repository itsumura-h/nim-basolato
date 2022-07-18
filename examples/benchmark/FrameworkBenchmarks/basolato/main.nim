# framework
import basolato
# controller
import app/http/controllers/benchmark_controller


let ROUTES = @[
  Route.get("/json", benchmark_controller.json),
  Route.get("/plaintext", benchmark_controller.plainText),
  Route.get("/db", benchmark_controller.db),
  Route.get("/queries", benchmark_controller.query),
  Route.get("/fortunes", benchmark_controller.fortunes),
  Route.get("/updates", benchmark_controller.update),
  Route.get("/cached-queries", benchmark_controller.cached),
]

serve(ROUTES)
