# framework
import basolato
# middleware
import ./app/http/middlewares/auth_middleware
import ./app/http/middlewares/set_headers_middleware
# controller
import ./app/http/controllers/welcome_controller


let routes = @[
  Route.group("", @[
    Route.get("/", welcome_controller.index),

    Route.group("/api", @[
      Route.get("/index", welcome_controller.indexApi),
    ])
    .middleware(set_headers_middleware.setCorsHeadersMiddleware),
  ])
  .middleware(set_headers_middleware.setSecureHeadersMiddlware)
  .middleware(auth_middleware.checkCsrfTokenMiddleware),
]

serve(routes)
