import std/asyncdispatch
import std/json
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/request_validation
# view
import ../views/presenters/app_presenter
import ../views/layouts/app/app_layout
import ../views/pages/validation/validation_page

proc index*(context:Context):Future[Response] {.async.} =
  let page = validationPage().await

  let title = "Validation view"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)
  let view = appLayout(appLayoutModel, page)
  return render(view)

proc store*(context:Context):Future[Response] {.async.} =
  let validation = RequestValidation.new(context.params)
  # email
  validation.required("email", attribute="mail address")
  validation.email("email", attribute="mail address")
  # password
  validation.required("password")
  validation.required("password_confirmation", attribute="password confirmation")
  validation.confirmed("password")
  # number, float
  validation.required("number")
  validation.required("float")
  validation.betweenNum("number", 1, 10)
  validation.betweenNum("float", 0.1, 1.0)
  if validation.hasErrors:
    context.storeValidationResult(validation).await
  return redirect("/sample/validation")
