import std/asyncdispatch
import basolato/view

type RegisterTemplateModel* = object
  errors*: seq[string]
  name*: string
  email*: string
  csrfToken*: string

proc new*(
  _: type RegisterTemplateModel,
  context: Context
): Future[RegisterTemplateModel] {.async.} =
  let (params, errors) = context.getParamsWithErrorsList().await
  let name = params.old("name")
  let email = params.old("email")
  let csrfToken = context.csrfToken().toString()
  return RegisterTemplateModel(errors: errors, name: name, email: email, csrfToken: csrfToken)
