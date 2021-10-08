import re
# framework
import ../../src/basolato
# middleware
import app/http/middlewares/auth_middleware
import app/http/middlewares/cors_middleware
import app/http/middlewares/example_middleware
# controllers
import app/http/controllers/page_display_controller
import app/http/controllers/cookie_controller
import app/http/controllers/login_controller
import app/http/controllers/flash_controller
import app/http/controllers/file_upload_controller
import app/http/controllers/validation_controller

var routes = Routes.new()
routes.middleware(re".*", auth_middleware.checkCsrfTokenMiddleware)
routes.middleware(re"/api/.*", cors_middleware.setCorsHeadersMiddleware)
routes.middleware(re"/sample/custom-headers", example_middleware.setMiddleware1)
routes.middleware(re"/sample/custom-headers", example_middleware.setMiddleware2)

routes.get("/", page_display_controller.index)
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

  routes.get("/cookie", cookie_controller.index)
  routes.post("/cookie", cookie_controller.store)
  routes.post("/cookie/update", cookie_controller.update)
  routes.post("/cookie/delete", cookie_controller.delete)
  routes.post("/cookie/destroy", cookie_controller.destroy)

  routes.get("/login", login_controller.index)
  routes.post("/login", login_controller.store)
  routes.post("/logout", login_controller.destroy)

  routes.get("/flash", flash_controller.index)
  routes.post("/flash", flash_controller.store)

  routes.get("/file-upload", file_upload_controller.index)
  routes.post("/file-upload", file_upload_controller.store)
  routes.post("/file-upload/delete", file_upload_controller.destroy)

  routes.get("/validation", validation_controller.index)
  routes.post("/validation", validation_controller.store)


serve(routes)
