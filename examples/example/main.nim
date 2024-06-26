# framework
import ../../src/basolato
import ../../src/basolato/middleware/session_from_cookie_middleware
# import ../../src/basolato/middleware/check_csrf_token_middleware
# middleware
# import app/http/middlewares/session_middleware
# import app/http/middlewares/auth_middleware
import app/http/middlewares/auth_middleware
import app/http/middlewares/set_headers_middleware
import app/http/middlewares/example_middleware
# controller
import app/http/controllers/welcome_controller
import app/http/controllers/page_display_controller
import app/http/controllers/cookie_controller
import app/http/controllers/login_controller
import app/http/controllers/flash_controller
import app/http/controllers/file_upload_controller
import app/http/controllers/validation_controller
import app/http/controllers/api_controller


let routes = @[
  Route.group("", @[
    Route.get("/", page_display_controller.index)
      .middleware(example_middleware.setMiddleware1),
    Route.group("/sample", @[
      Route.get("/welcome", page_display_controller.welcome)
        .middleware(example_middleware.setMiddleware2),
      Route.get("/welcome-scf", page_display_controller.welcomeScf)
        .middleware(example_middleware.setMiddleware2),
      Route.get("/fib/{num:int}", page_display_controller.fib),
      Route.get("/with-style", page_display_controller.withStylePage),
      Route.get("/babylon-js", page_display_controller.babylonJsPage),
      Route.get("/api", page_display_controller.displayApiPage),

      Route.get("/custom-headers", page_display_controller.customHeaders),
      Route.get("/dd", page_display_controller.presentDd),
      Route.get("/error/{id:int}", page_display_controller.errorPage),
      Route.get("/error-redirect/{id:int}", page_display_controller.errorRedirect),

      Route.get("/cookie", cookie_controller.index),
      Route.post("/cookie", cookie_controller.store),
      Route.post("/cookie/update", cookie_controller.update),
      Route.post("/cookie/delete", cookie_controller.delete),
      Route.post("/cookie/destroy", cookie_controller.destroy),

      Route.get("/login", login_controller.index),
      Route.post("/login", login_controller.store),
      Route.post("/logout", login_controller.destroy),

      Route.get("/flash", flash_controller.index),
      Route.post("/flash", flash_controller.store),

      Route.get("/file-upload", file_upload_controller.index),
      Route.post("/file-upload", file_upload_controller.store),
      Route.post("/file-upload/delete", file_upload_controller.destroy),

      Route.get("/validation", validation_controller.index),
      Route.post("/validation", validation_controller.store),

      Route.get("/web-socket-component", page_display_controller.webSocketComponent),
      Route.get("/web-socket", page_display_controller.webSocketPage),
      Route.get("/ws", page_display_controller.webSocket),
    ])
    .middleware(example_middleware.setMiddleware3)
    .middleware(auth_middleware.checkCsrfToken)
    .middleware(auth_middleware.sessionFromCookie),

    Route.group("/api", @[
      Route.get("/sample", api_controller.get),
      Route.post("/sample", api_controller.post),
      Route.patch("/sample", api_controller.patch),
      Route.put("/sample", api_controller.put),
      Route.delete("/sample", api_controller.delete),
    ])
    .middleware(set_headers_middleware.setCorsHeaders),
  ])
  .middleware(set_headers_middleware.setSecureHeaders),
]

let settings = Settings.new(
  host="0.0.0.0"
)

serve(routes, settings)
