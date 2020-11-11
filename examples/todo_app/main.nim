# framework
import ../../src/basolato
# controller
# import app/controllers/welcome_controller
import app/controllers/sign_controller
# middleware
import app/middlewares/auth_middleware

var routes = newRoutes()
routes.middleware(".*", auth_middleware.checkCsrfTokenMiddleware)
# routes.get("/", welcome_controller.index)
routes.get("/signup", sign_controller.signup_page)
routes.post("/signup", sign_controller.signup)
routes.get("/delete-account", sign_controller.delete_account_page)
routes.post("/delete-account", sign_controller.delete_account)

routes.get("/signin", sign_controller.signin_page)
routes.post("/signin", sign_controller.signin)
routes.post("/signout", sign_controller.signout)

serve(routes)
