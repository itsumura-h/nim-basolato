import std/asyncdispatch
import basolato/view
import ../../templates/login/login_template
import ../../templates/login/login_template_model
import ../../layouts/app/app_layout
import ../../layouts/app/app_layout_model

proc loginPageView*(context: Context): Future[Component] {.async.} =
  let model = LoginTemplateModel.new(context).await
  let body = loginTemplate(model)
  
  let appLayoutModel = AppLayoutModel.new(context, "Login", body).await
  return appLayout(appLayoutModel)
