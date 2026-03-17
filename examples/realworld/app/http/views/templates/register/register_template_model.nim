import std/asyncdispatch
import basolato/view

type RegisterTemplateModel* = object
  errors*: seq[string]
  name*: string
  email*: string
  csrfToken*: CsrfToken

proc new*(
  _: type RegisterTemplateModel,
  context: Context
): Future[RegisterTemplateModel] {.async.} =
  let params = context.getParams().await
  let errors = context.getErrors().await
  let name = params.old("name")
  let email = params.old("email")
  let csrfToken = context.csrfToken()
  return RegisterTemplateModel(
    errors: errors,
    name: name,
    email: email,
    csrfToken: csrfToken
  )
