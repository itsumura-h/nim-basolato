import std/asyncdispatch
import basolato/view
import ../../templates/register/register_template
import ../../layouts/app/app_layout


proc registerPage*():Future[Component] {.async.} =  
  let tmpl = registerTemplate().await
  return appLayout("Register", tmpl).await
