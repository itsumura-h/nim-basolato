import json
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/request_validation
# view
import ../views/pages/sample/validation_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  return render(await validationView(client))

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("show")

proc create*(request:Request, params:Params):Future[Response] {.async.} =
  return render("create")

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  params.required(
    ["name", "email", "password", "password_confirmation", "number", "float"],
    attributes = @["名前", "メールアドレス", "パスワード", "パスワード確認", "数字", "小数"]
  )
  params.email("email", attribute="メールアドレス")
  params.password("password", attribute="パスワード")
  params.password("password_confirmation", attribute="パスワード確認")
  params.confirmed("password", attribute="パスワード")
  params.betweenNum("number", 1, 10, attribute="数字")
  params.betweenNum("float", 0.1, 1.0, attribute="小数")
  if params.hasErrors:
    let client = await newClient(request)
    await client.storeValidationResult(params)
  return redirect("/sample/validation")

proc edit*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("edit")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("update")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("destroy")
