import re
# framework
import ../../src/basolato
# controller
# import app/controllers/welcome_controller
import app/http/controllers/sign_controller
import app/http/controllers/todo_controller
# middleware
import app/http/middlewares/auth_middleware

var routes = newRoutes()
routes.middleware(re".*", auth_middleware.checkCsrfTokenMiddleware)
routes.middleware(
  re"^(?!.*(signin|signup|delete-account)).*$",
  auth_middleware.checkSessionIdMiddleware
)

routes.get("/signup", sign_controller.signUpPage)
routes.post("/signup", sign_controller.signUp)

routes.get("/signin", sign_controller.signInPage)
routes.post("/signin", sign_controller.signIn)
routes.post("/signout", sign_controller.signOut)

routes.get("/delete-account", sign_controller.deleteAccountPage)
routes.post("/delete-account", sign_controller.deleteAccount)

routes.get("/", todo_controller.index)
routes.post("/", todo_controller.store)
routes.post("/change-status/{id:int}", todo_controller.changeStatus)
routes.post("/delete/{id:int}", todo_controller.destroy)
routes.get("/{id:int}", todo_controller.show)
routes.post("/{id:int}", todo_controller.update)

serve(routes)
