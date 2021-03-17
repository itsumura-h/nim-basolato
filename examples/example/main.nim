import re
import ../../src/basolato
# controller
import app/http/controllers/page_display_controller
import app/http/controllers/cookie_controller
import app/http/controllers/login_controller
import app/http/controllers/flash_controller
import app/http/controllers/file_upload_controller
import app/http/controllers/benchmark_controller
# import app/http/controllers/validation_controller
# middleware
import app/http/middlewares/auth_middleware
import app/http/middlewares/cors_middleware

var routes = newRoutes()

routes.middleware(re".*", auth_middleware.checkCsrfTokenMiddleware)
routes.middleware(@[HttpGet, HttpOptions], re"/api/.*", cors_middleware.setCorsMiddleware)

routes.get("/", page_display_controller.index)
routes.get("/api/test1", benchmark_controller.test1)
routes.get("/api/test2", benchmark_controller.test2)
routes.put("/api/test2", benchmark_controller.test2)
groups "/sample":
  routes.get("/welcome", page_display_controller.welcome)
  routes.get("/fib/{num:int}", page_display_controller.fib)
  routes.get("/with-style", page_display_controller.withStylePage)

  routes.get("/react", page_display_controller.react)
  routes.get("/material-ui", page_display_controller.materialUi)
  routes.get("/vuetify", page_display_controller.vuetify)
  routes.get("/custom-headers", page_display_controller.customHeaders)
  routes.get("/dd", page_display_controller.presentDd)
  routes.get("/error/{id:int}", page_display_controller.errorPage)
  routes.get("/error-redirect/{id:int}", page_display_controller.errorRedirect)

  routes.get("/cookie", cookie_controller.indexCookie)
  routes.post("/cookie", cookie_controller.storeCookie)
  routes.post("/cookie/update", cookie_controller.updateCookie)
  routes.post("/cookie/delete", cookie_controller.destroyCookie)
  # routes.post("/cookie/delete-all", cookie_controller.destroyCookies)

  routes.get("/login", login_controller.index)
  routes.post("/login", login_controller.store)
  routes.post("/logout", login_controller.destroy)

  routes.get("/flash", flash_controller.index)
  routes.post("/flash", flash_controller.store)
  routes.post("/flash/leave", flash_controller.destroy)

  routes.get("/file-upload", file_upload_controller.index)
  routes.post("/file-upload", file_upload_controller.store)
  routes.post("/file-upload/delete", file_upload_controller.destroy)

  # routes.get("/validation", validation_controller.index)
  # routes.post("/validation", validation_controller.store)

serve(routes)
