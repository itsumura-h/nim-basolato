import std/asyncdispatch
import basolato/view
import ../../templates/setting/setting_template
import ../../layouts/app/app_layout

proc settingPageView*(context: Context): Future[Component] {.async.} =
  let tmpl = await settingTemplate(context)
  return await appLayout(context, "Setting", tmpl)
