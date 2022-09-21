import
  ../../src/basolato2,
  ./app/controllers,
  ./app/middlewares


let ROUTES = @[
  Route.get("/", controllers.index)
    .middleware(middlewares.setSecureHeadersMiddlware)
    .middleware(middlewares.setCorsHeadersMiddleware),
  Route.get("/error/{id:int}", controllers.index)
    .middleware(middlewares.setSecureHeadersMiddlware)
    .middleware(middlewares.setCorsHeadersMiddleware),
  Route.post("/error/{id:int}", controllers.index).middleware(middlewares.setSecureHeadersMiddlware),
  Route.get("/query", controllers.query)
]

serve(ROUTES)
