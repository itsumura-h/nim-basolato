import std/asyncdispatch
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/request_validation
#view
import ../views/pages/login/login_page


proc loginPage*(context:Context):Future[Response] {.async.} =
  let page = loginPageView(context).await
  return render(page)


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
  context.session.set("name", name).await
  context.login().await
  return redirect("/sample/login")


proc destroy*(context:Context):Future[Response] {.async.} =
  await context.logout()
  await context.session.delete("name")
  return redirect("/sample/login")
