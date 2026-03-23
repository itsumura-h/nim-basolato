import std/asyncdispatch
import basolato/view
import ../../templates/setting/setting_template
import ../../layouts/app/app_layout
import ../../layouts/app/app_layout_model

proc settingPageView*(context: Context): Future[Component] {.async.} =
  let tmpl = await settingTemplate(context)
  let appLayoutModel = AppLayoutModel.new(context, "Setting", tmpl).await
  return appLayout(appLayoutModel)
