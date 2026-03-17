import std/asyncdispatch
import basolato/controller
import basolato/request_validation
import ../views/pages/setting/setting_page
import ../../models/aggregates/user/user_entity
import ../../usecases/update_setting_usecase



proc settingPage*(context:Context):Future[Response] {.async.} =
  let page = settingPageView(context).await
  return render(page)


proc updateSettings*(context:Context):Future[Response] {.async.} =
  let validation = RequestValidation.new(context)
  validation.required("name", "User Name")
  validation.required("email", "Email")
  validation.email("email", "Email")
  if context.params.getStr("password").len > 0:
    validation.password("password", "Password")
  if context.params.getStr("image").len > 0:
    validation.url("image", "URL of your picture")

  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/settings")

  try:
    let userId = context.get("user_id").await
    let name = context.params.getStr("name")
    let email = context.params.getStr("email")
    let password = context.params.getStr("password")
    let bio = context.params.getStr("bio")
    let image = context.params.getStr("image")

    let usecase = UpdateSettingUsecase.new()
    usecase.invoke(userId, name, email, password, bio, image).await
    return redirect("/")
  except:
    let error = getCurrentExceptionMsg()
    context.storeError(error).await
    return redirect("/settings")
