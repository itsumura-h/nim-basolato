import std/asyncdispatch
import basolato/view
import ../../templates/login/login_template
import ../../layouts/app/app_layout

proc loginPageView*(context: Context): Future[Component] {.async.} =
  let tmpl = loginTemplate(context).await
  return appLayout(context, "Login", tmpl).await
