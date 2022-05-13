# framework
import ../../src/basolato
# middleware
import app/http/middlewares/auth_middleware
import app/http/middlewares/set_headers_middleware
import app/http/middlewares/example_middleware
# controllers
import app/http/controllers/page_display_controller
import app/http/controllers/cookie_controller
import app/http/controllers/login_controller
import app/http/controllers/flash_controller
import app/http/controllers/file_upload_controller
import app/http/controllers/validation_controller


let ROUTES = @[
  Route.group("", @[
    Route.get("/", page_display_controller.index)
      .middleware(example_middleware.setMiddleware1),
    Route.group("/sample", @[
      Route.get("/welcome", page_display_controller.welcome)
        .middleware(example_middleware.setMiddleware2),
      Route.get("/fib/{num:int}", page_display_controller.fib),
      Route.get("/with-style", page_display_controller.withStylePage),
      Route.get("/babylon-js", page_display_controller.babylonJsPage),

      Route.get("/react", page_display_controller.react),
      Route.get("/material-ui", page_display_controller.materialUi),
      Route.get("/vuetify", page_display_controller.vuetify),

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
    .middleware(example_middleware.setMiddleware3),
    Route.group("/api", @[])
    .middleware(set_headers_middleware.setCorsHeadersMiddleware)
  ])
  .middleware(set_headers_middleware.setSecureHeadersMiddlware)
  .middleware(auth_middleware.checkCsrfTokenMiddleware)
]

serve(ROUTES)
