import std/asyncdispatch
import basolato/view

type RegisterTemplateModel* = object
  errors*: seq[string]
  name*:string
  email*:string


proc new*(_:type RegisterTemplateModel):Future[RegisterTemplateModel] {.async.} =
  let context = context()
  let (params, errors) = context.getParamsWithErrorsList().await
  let name = params.old("name")
  let email = params.old("email")
  return RegisterTemplateModel(errors: errors, name: name, email: email)
