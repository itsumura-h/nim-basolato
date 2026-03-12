import basolato/view
import std/asyncdispatch

type LoginTemplateModel* = object
  errors*:seq[string]
  email*:string

proc new*(_:type LoginTemplateModel):Future[LoginTemplateModel] {.async.} =
  let context = context()
  let (params, errors) = context.getParamsWithErrorsList().await
  return LoginTemplateModel(errors: errors, email: params.old("email"))
