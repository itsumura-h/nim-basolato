import std/asyncdispatch
import basolato/view
import ../../templates/register/register_template
import ../../templates/register/register_template_model
import ../../layouts/app/app_layout
import ../../layouts/app/app_layout_model

proc registerPageView*(context: Context): Future[Component] {.async.} =
  let model = RegisterTemplateModel.new(context).await
  let body = registerTemplate(model)
  let appLayoutModel = AppLayoutModel.new(context, "Register", body).await
  return appLayout(appLayoutModel)
