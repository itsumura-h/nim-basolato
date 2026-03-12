import std/asyncdispatch
import std/strutils
import basolato/controller
import basolato/request_validation
import ../views/pages/login/login_page
import ../views/pages/register/register_page
import ../../usecases/login_usecase
import ../../usecases/register_usecase


proc signInPage*(context:Context):Future[Response] {.async.} =
  let page = loginPage().await
  return render(page)


proc signIn*(context:Context):Future[Response] {.async.} =
  let validation = RequestValidation.new(context)
  validation.required("email", "Email")
  validation.email("email", "Email")
  validation.required("password", "Password")
  validation.password("password", "Password")

  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/login")

  let email = context.params.getStr("email")
  let password = context.params.getStr("password")

  try:
    let usecase = LoginUsecase.new()
    let (id, name) = usecase.invoke(email, password).await
    context.login().await
    context.set("user_id", id).await
    context.set("user_name", name).await
    return redirect("/")
  except:
    let error = getCurrentExceptionMsg()
    context.storeError(error.split("\n")[0]).await
    return redirect("/login")


proc signUpPage*(context:Context):Future[Response] {.async.} =
  let page = registerPage().await
  return render(page)


proc signUp*(context:Context):Future[Response] {.async.} =
  let validation = RequestValidation.new(context)
  validation.required("name", "Username")
  validation.required("email", "Email")
  validation.email("email", "Email")
  validation.required("password", "Password")
  validation.password("password", "Password")

  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/register")

  let name = context.params.getStr("name")
  let email = context.params.getStr("email")
  let password = context.params.getStr("password")

  try:
    let usecase = RegisterUsecase.new()
    let (id, name) = usecase.invoke(name, email, password).await
    context.login().await
    context.set("user_id", id).await
    context.set("user_name", name).await
    return redirect("/")
  except:
    let error = getCurrentExceptionMsg()
    context.storeError(error).await
    return redirect("/register")


proc signOut*(context:Context):Future[Response] {.async.} =
  context.logout().await
  context.delete("user_id").await
  context.delete("user_name").await
  return redirect("/")
