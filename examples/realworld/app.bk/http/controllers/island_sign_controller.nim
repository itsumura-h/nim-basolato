# framework
import basolato/controller
import basolato/request_validation
import basolato/view
import ../../presenters/sign_up/sign_up_presenter
import ../../presenters/sign_in/sign_in_presenter
import ../../usecases/create_user_usecase
import ../../usecases/login_usecase
import ../views/pages/signup/signup_view
import ../views/pages/signin/signin_view


proc signUpPage*(context:Context, params:Params):Future[Response] {.async.} =
  let oldName = params.old("username")
  let oldEmail = params.old("email")
  # let viewModel = SignUpViewModel.new(oldName, oldEmail)
  let signUpPresenter = SignUpPresenter.new()
  let viewModel = signUpPresenter.invoke(oldName, oldEmail)
  let view = islandSignUpView(viewModel)
  return render(view)

proc signUp*(context:Context, params:Params):Future[Response] {.async.} =
  let validation = RequestValidation.new(params)
  validation.required("username")
  validation.required("email")
  validation.email("email")
  validation.required("password")

  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return render(Http400, "")
  
  let name = params.getStr("username")
  let email = params.getStr("email")
  let password = params.getStr("password")

  let usecase = CreateUserUsecase.new()
  let id = usecase.invoke(name, email, password).await
  context.login().await
  context.set("id", id).await
  context.set("name", name).await

  var header = newHttpHeaders()
  header.add("HX-Redirect", "/")
  return render("", header)


proc signInPage*(context:Context, params:Params):Future[Response] {.async.} =
  let oldEmail = params.old("email")
  # let viewModel = SignInViewModel.new(oldEmail)
  let signInPresenter = SignInPresenter.new()
  let viewModel = signInPresenter.invoke(oldEmail)
  let view = islandSignInView(viewModel)
  return render(view)


proc signIn*(context:Context, params:Params):Future[Response] {.async.} =
  let validation = RequestValidation.new(params)
  validation.required("email")
  validation.email("email")
  validation.required("password")

  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return render(Http400, "")

  let email = params.getStr("email")
  let password = params.getStr("password")

  let usecase = LoginUsecase.new()
  let (id, name) = usecase.invoke(email, password).await 
  context.login().await
  context.set("id", id).await
  context.set("name", name).await

  var header = newHttpHeaders()
  header.add("HX-Redirect", "/")
  return render("", header)


proc logout*(context:Context, params:Params):Future[Response] {.async.} =
  context.logout().await
  context.delete("id").await
  context.delete("name").await
  var header = newHttpHeaders()
  header.add("HX-Redirect", "/")
  return render("", header)
