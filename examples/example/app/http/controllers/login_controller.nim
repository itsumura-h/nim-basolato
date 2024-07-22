import std/asyncdispatch
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/request_validation
#view
import ../views/pages/login/login_page
import ../views/layouts/app/app_layout
import ../views/presenters/app_presenter


proc index*(context:Context):Future[Response] {.async.} =
  const title = "Login Page"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let page = loginPage().await
  let view = appLayout(appLayoutModel, page)
  return render(view)


proc store*(context:Context):Future[Response] {.async.} =
  let validation = RequestValidation.new(context)
  validation.required("name")
  validation.required("password")
  validation.password("password")
  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/sample/login")

  let name = context.params.getStr("name")
  let password = context.params.getStr("password")
  # client
  context.set("name", name).await
  context.login().await
  return redirect("/sample/login")


proc destroy*(context:Context):Future[Response] {.async.} =
  await context.logout()
  await context.delete("name")
  return redirect("/sample/login")
