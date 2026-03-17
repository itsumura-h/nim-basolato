import std/asyncdispatch
import basolato/view
import ../../templates/register/register_template
import ../../layouts/app/app_layout

proc registerPageView*(context: Context): Future[Component] {.async.} =
  let tmpl = await registerTemplate(context)
  return await appLayout(context, "Register", tmpl)
