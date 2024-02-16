# framework
import ../../src/basolato
import ../../src/basolato/middleware/session_from_cookie_middleware
import ../../src/basolato/middleware/check_csrf_token_middleware
# middleware
# import app/http/middlewares/session_middleware
# import app/http/middlewares/auth_middleware
# controller
import app/http/controllers/test_controller


let routes = @[
  # test controller
  Route.get("/renderStr", test_controller.renderStr),
  Route.get("/renderHtml", test_controller.renderHtml),
  Route.get("/renderTemplate", test_controller.renderTemplate),
  Route.get("/renderJson", test_controller.renderJson),
  Route.get("/status500", test_controller.status500),
  Route.get("/status500json", test_controller.status500json),
  Route.get("/redirect", test_controller.redirect),
  Route.get("/error-redirect", test_controller.errorRedirect),
  Route.get("/redirect-with-header", test_controller.redirectWithHeader),
  Route.get("/error-redirect-with-header", test_controller.errorRedirectWithHeader),

  # test helper
  Route.get("/dd", test_controller.dd),

  # test routing
  Route.get("/test_routing", test_controller.getAction),
  Route.post("/test_routing", test_controller.postAction),
  Route.patch("/test_routing", test_controller.patchAction),
  Route.put("/test_routing", test_controller.putAction),
  Route.delete("/test_routing", test_controller.deleteAction),

  Route.group("", @[
    # test response
    Route.get("/set-header", test_controller.setHeader),
    Route.get("/set-cookie", test_controller.setCookie),
    Route.get("/set-auth", test_controller.setAuth),
    Route.get("/destroy-auth", test_controller.destroyAuth),

    Route.get("/csrf/test_routing", test_controller.getCsrf),
    Route.post("/csrf/test_routing", test_controller.postAction),
    Route.post("/session/test_routing", test_controller.postAction)
  ])
  .middleware(checkCsrfToken)
  .middleware(sessionFromCookie),
]

serve(routes)
