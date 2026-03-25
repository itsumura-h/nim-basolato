# framework
import basolato
# middleware
import ./app/http/middlewares/session_middleware
import ./app/http/middlewares/set_headers_middleware
# controller
import ./app/http/controllers/welcome_controller


let routes = @[
  Route.group("", @[
    Route.group("", @[
      Route.get("/", welcome_controller.welcomePage),
    ])
    .middleware(session_middleware.checkCsrfToken)
    .middleware(session_middleware.sessionFromCookie),

    Route.group("/api", @[
      Route.get("/index", welcome_controller.indexApi),
    ])
    .middleware(set_headers_middleware.setSecureHeaders)
  ])
  .middleware(set_headers_middleware.setCorsHeaders)
]

let settings = Settings.new(
  host = "0.0.0.0"
)

serve(routes, settings)
