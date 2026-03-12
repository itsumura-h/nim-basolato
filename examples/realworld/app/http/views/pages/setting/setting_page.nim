import std/asyncdispatch
import basolato/view
import ../../templates/setting/setting_template
import ../../layouts/app/app_layout


proc settingPage*():Future[Component] {.async.} =
  let tmpl = settingTemplate().await
  return appLayout("Setting", tmpl).await
