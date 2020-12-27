import asyncdispatch, httpcore, tables
# framework
import ../../src/basolato
# middleware
import app/middlewares/custom_headers_middleware
import app/middlewares/auth_middleware
# controller
import app/controllers/test_controller

var routes = newRoutes()
routes.middleware("/csrf/*", checkCsrfTokenMiddleware)
routes.middleware("/session/*", checkAuthTokenMiddleware)

# test controller
routes.get("/renderStr", test_controller.renderStr)
routes.get("/renderHtml", test_controller.renderHtml)
routes.get("/renderTemplate", test_controller.renderTemplate)
routes.get("/renderJson", test_controller.renderJson)
routes.get("/status500", test_controller.status500)
routes.get("/status500json", test_controller.status500json)
routes.get("/redirect", test_controller.redirect)
routes.get("/error_redirect", test_controller.error_redirect)

# test helper
routes.get("/dd", test_controller.dd)

# test response
routes.get("/set-header", test_controller.setHeader)
routes.get("/set-cookie", test_controller.setCookie)
routes.get("/set-auth", test_controller.setAuth)
routes.get("/destroy-auth", test_controller.destroyAuth)

# test routing
routes.get("/test_routing", test_controller.getAction)
routes.post("/test_routing", test_controller.postAction)
routes.patch("/test_routing", test_controller.patchAction)
routes.put("/test_routing", test_controller.putAction)
routes.delete("/test_routing", test_controller.deleteAction)

routes.post("/csrf/test_routing", test_controller.postAction)
routes.post("/session/test_routing", test_controller.postAction)

serve(routes)
