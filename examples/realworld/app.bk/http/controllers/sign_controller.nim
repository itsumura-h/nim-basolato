import std/asyncdispatch
import std/options
# framework
import basolato/controller
import basolato/view
import ../../presenters/app/app_presenter
import ../../presenters/sign_up/sign_up_presenter
import ../../presenters/sign_in/sign_in_presenter
import ../views/pages/signup/signup_view
import ../views/pages/signin/signin_view


proc signUpPage*(context:Context, params:Params):Future[Response] {.async.} =
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      none(string)

  let appPresenter = AppPresenter.new()
  let appViewModel = appPresenter.invoke(loginUserId, "Sign Up ― Conduit").await
  let oldName = params.old("username")
  let oldEmail = params.old("email")
  let signUpPresenter = SignUpPresenter.new()
  let viewModel = signUpPresenter.invoke(oldName, oldEmail)
  let view = signUpView(appViewModel, viewModel)
  return render(view)


proc signInPage*(context:Context, params:Params):Future[Response] {.async.} =
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      none(string)

  let appPresenter = AppPresenter.new()
  let appViewModel = appPresenter.invoke(loginUserId, "Sign In ― Conduit").await
  let oldEmail = params.old("email")
  let signInPresenter = SignInPresenter.new()
  let viewModel = signInPresenter.invoke(oldEmail)
  let view = signInView(appViewModel, viewModel)
  return render(view)


proc logout*(context:Context, params:Params):Future[Response] {.async.} =
  context.logout().await
  context.delete("id").await
  context.delete("name").await
  return redirect("/")
