# framework
import ../src/basolato/routing
# middleware
# import middleware/custom_headers_middleware
import middleware/framework_middleware
# controller
import app/controllers/sign_up_controller
import app/controllers/login_controller
import app/controllers/posts_controller


router post:
  get "": route(newPostsController().index(request))
  get "/create": route(newPostsController().create())
  post "/create": route(newPostsController().store(request))
  get "/@id": route(newPostsController().show(@"id"))
  get "/@id/edit": route(newPostsController().edit(@"id"))
  post "/@id/edit": route(newPostsController().update(@"id", request))
  # post "/@id/delete": route(newPostsController().destroy(@"id"))

routes:
  # Framework
  error Http404:
    http404Route
  error Exception:
    exceptionRoute
  before:
    framework

  get "/": redirect("/posts")

  get "/signUp": route(newSignUpController().create())
  post "/signUp": route(newSignUpController().store(request))

  get "/login": route(newLoginController().create())
  post "/login": route(newLoginController().store())
  get "/logout": route(newLoginController().destroy())
  extend post, "/posts"

runForever()
