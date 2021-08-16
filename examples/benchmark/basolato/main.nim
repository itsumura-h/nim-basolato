import re
# framework
import basolato
# controller
import app/http/controllers/benchmark_controller

var routes = newRoutes()

routes.get("/json", benchmark_controller.json)
routes.get("/plaintext", benchmark_controller.plainText)
routes.get("/db", benchmark_controller.db)
routes.get("/queries", benchmark_controller.query)
routes.get("/fortunes", benchmark_controller.fortunes)
routes.get("/updates", benchmark_controller.update)

serve(routes)
