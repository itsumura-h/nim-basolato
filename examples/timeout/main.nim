import re
# framework
import basolato
# controller
import app/http/controllers/welcome_controller
# middleware
import app/http/middlewares/auth_middleware
import app/http/middlewares/cors_middleware

var routes = newRoutes()
routes.middleware(re".*", auth_middleware.checkCsrfTokenMiddleware)
routes.middleware(re"/api/.*", cors_middleware.setCorsHeadersMiddleware)

routes.get("/", welcome_controller.index)

groups "/api":
  routes.get("/index", welcome_controller.indexApi)

serve(routes)
