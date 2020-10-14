# framework
import basolato
# controller
import app/controllers/welcome_controller
import app/controllers/benchmark_controller

var routes = newRoutes()
routes.get("/", welcome_controller.index)

routes.get("/json", benchmark_controller.json)
routes.get("/plaintext", benchmark_controller.plainText)
routes.get("/db", benchmark_controller.db)
routes.get("/queries", benchmark_controller.queries)
routes.get("/fortunes", benchmark_controller.fortunes)
routes.get("/updates", benchmark_controller.updates)

serve(routes)
