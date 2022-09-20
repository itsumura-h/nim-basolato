import
  std/asyncdispatch,
  std/options,
  std/json,
  std/sequtils,
  ../../src/basolato2,
  ./app/controllers


let ROUTES = @[
  Route.get("/", controllers.index),
  Route.post("/", controllers.index),
  Route.get("/query", controllers.query)
]

serve(ROUTES)
