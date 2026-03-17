import std/asyncdispatch
import basolato/view

type LoginTemplateModel* = object
  errors*: seq[string]
  email*: string
  csrfToken*: CsrfToken

proc new*(
  _: type LoginTemplateModel,
  context: Context
): Future[LoginTemplateModel] {.async.} =
  let params = context.getParams().await
  let errors = context.getErrors().await
  let email = params.old("email")
  let csrfToken = context.csrfToken()
  return LoginTemplateModel(
    errors: errors,
    email: email,
    csrfToken: csrfToken
  )
