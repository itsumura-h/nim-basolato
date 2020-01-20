# framework
# import ../src/basolato/routing
import ../src/basolato/private
# middleware
# import middleware/custom_headers_middleware
import middleware/framework_middleware
# controller
import app/controllers/sign_up_controller
import app/controllers/login_controller
import app/controllers/posts_controller


router post:
  get "": route(newPostsController(request).index())
  get "/create": route(newPostsController(request).create())
  post "/create": route(newPostsController(request).store())
  get "/@id": route(newPostsController(request).show(@"id"))
  get "/@id/edit": route(newPostsController(request).edit(@"id"))
  post "/@id/edit": route(newPostsController(request).update(@"id"))
  # post "/@id/delete": route(newPostsController().destroy(@"id"))

routes:
  # Framework
  error Http404:
    http404Route
  error Exception:
    exceptionRoute
  before:
    framework

  get "/": route(redirect("/posts"))

  get "/signUp": route(newSignUpController(request).create())
  post "/signUp": route(newSignUpController(request).store())

  get "/login": route(newLoginController(request).create())
  post "/login": route(newLoginController(request).store())
  get "/logout": route(newLoginController(request).destroy())

  extend post, "/posts"

runForever()
