import std/asyncdispatch
import basolato/view

type LoginTemplateModel* = object
  errors*: seq[string]
  email*: string
  csrfToken*: string

proc new*(
  _: type LoginTemplateModel,
  context: Context
): Future[LoginTemplateModel] {.async.} =
  let (params, errors) = context.getParamsWithErrorsList().await
  let email = params.old("email")
  let csrfToken = context.csrfToken().toString()
  return LoginTemplateModel(
    errors: errors,
    email: email,
    csrfToken: csrfToken
  )
