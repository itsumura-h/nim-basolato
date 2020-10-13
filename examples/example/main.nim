import asynchttpserver, asyncdispatch, httpcore, re
import ../../src/basolato
# controller
import app/controllers/page_display_controller
import app/controllers/cookie_controller
import app/controllers/login_controller
import app/controllers/flash_controller
import app/controllers/file_upload_controller
# middleware
import app/middlewares/auth_middleware

var routes = newRoutes()

routes.middleware(".*", auth_middleware.checkCsrfTokenMiddleware)
routes.middleware("/sample/.*", auth_middleware.chrckAuthTokenMiddleware)

routes.get("/", page_display_controller.index)
groups "/sample":
  routes.get("/welcome", page_display_controller.welcome)
  routes.get("/fib/{num:int}", page_display_controller.fib)
  routes.get("/react", page_display_controller.react)
  routes.get("/material-ui", page_display_controller.materialUi)
  routes.get("/vuetify", page_display_controller.vuetify)
  routes.get("/custom-headers", page_display_controller.customHeaders)
  routes.get("/dd", page_display_controller.presentDd)

  routes.get("/cookie", cookie_controller.indexCookie)
  routes.post("/cookie", cookie_controller.storeCookie)
  routes.post("/cookie/update", cookie_controller.updateCookie)
  routes.post("/cookie/delete", cookie_controller.destroyCookie)
  routes.post("/cookie/delete-all", cookie_controller.destroyCookies)

  routes.get("/login", login_controller.indexLogin)
  routes.post("/login", login_controller.storeLogin)
  routes.post("/logout", login_controller.destroyLogin)

  routes.get("/flash", flash_controller.index)
  routes.post("/flash", flash_controller.store)
  routes.post("/flash/leave", flash_controller.destroy)

  routes.get("/file-upload", file_upload_controller.index)
  routes.post("/file-upload", file_upload_controller.store)
  routes.post("/file-upload/delete", file_upload_controller.destroy)

serve(routes)
