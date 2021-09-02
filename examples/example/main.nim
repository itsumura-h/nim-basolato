import re
# framework
import ../../src/basolato
# controller
import app/http/controllers/welcome_controller
# middleware
import app/http/middlewares/auth_middleware
import app/http/middlewares/cors_middleware
import app/http/middlewares/example_middleware
# controllers
import app/http/controllers/page_display_controller

var routes = newRoutes()
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


serve(routes)
