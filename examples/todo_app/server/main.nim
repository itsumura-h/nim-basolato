import re
# framework
import ../../../src/basolato
# controller
# import app/controllers/welcome_controller
import app/http/controllers/sign_controller
import app/http/controllers/post_controller
# middleware
import app/http/middlewares/auth_middleware
import app/http/middlewares/cors_middleware

var routes = newRoutes()
routes.middleware(re".*", auth_middleware.checkCsrfTokenMiddleware)
routes.middleware(
  re"^(?!.*(signin|signup|delete-account)).*$",
  auth_middleware.checkSessionIdMiddleware
)
# routes.middleware(@[HttpGet, HttpOptions], re"/api/.*", cors_middleware.setCorsHeadersMiddleware)
routes.middleware(re"/api/.*", cors_middleware.setCorsHeadersMiddleware)

routes.get("/signup", sign_controller.signUpPage)
routes.post("/signup", sign_controller.signUp)

routes.get("/signin", sign_controller.signInPage)
routes.post("/signin", sign_controller.signIn)
routes.post("/signout", sign_controller.signOut)

routes.get("/delete-account", sign_controller.deleteAccountPage)
routes.post("/delete-account", sign_controller.deleteAccount)

routes.get("/", post_controller.index)
routes.post("/", post_controller.store)
routes.post("/change-status/{id:int}", post_controller.changeStatus)
routes.post("/delete/{id:int}", post_controller.destroy)
routes.get("/{id:int}", post_controller.show)
routes.post("/{id:int}", post_controller.update)

groups "/api":
  routes.post("/signin", sign_controller.signInApi)
  routes.post("/signout", sign_controller.signOutApi)
  routes.get("/posts", post_controller.indexApi)
  routes.post("/posts", post_controller.storeApi)
  routes.put("/change-status/{id:int}", post_controller.changeStatusApi)
  routes.delete("/posts/{id:int}", post_controller.destroyApi)
  routes.get("/posts/{id:int}", post_controller.showApi)
  routes.put("/posts/{id:int}", post_controller.updateApi)

serve(routes)
