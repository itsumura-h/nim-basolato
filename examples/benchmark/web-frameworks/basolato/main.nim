# framework
import basolato
# controller
import ./app/http/controllers/benchmark_controller


let routes = @[
  Route.get("/", benchmark_controller.index),
  Route.get("/user/{id:str}", benchmark_controller.show),
  Route.get("/user/{id:int}", benchmark_controller.show),
  Route.post("/user", benchmark_controller.store),
]

let settings = Settings.new(
  host="0.0.0.0"
)

serve(routes, settings)
