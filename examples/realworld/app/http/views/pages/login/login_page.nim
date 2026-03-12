import std/asyncdispatch
import basolato/view
import ../../templates/login/login_template
import ../../layouts/app/app_layout


proc loginPage*():Future[Component] {.async.} =
  let tmpl = loginTemplate().await
  return appLayout("Login", tmpl).await
