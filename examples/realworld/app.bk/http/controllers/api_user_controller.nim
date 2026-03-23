import std/json
# framework
import basolato/controller
# usecase
import ../../usecases/create_user_usecase

proc index*(context:Context, params:Params):Future[Response] {.async.} =
  return render("index")


proc show*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("show")


proc create*(context:Context, params:Params):Future[Response] {.async.} =
  let userParam = params.getJson("user")

  let errorMessage = newJArray()
  var hasError = false
  if not userParam.hasKey("username") or userParam["username"].getStr().len == 0:
    errorMessage.add(%"username is not found")
    hasError = true
  if not userParam.hasKey("email") or userParam["email"].getStr().len == 0:
    errorMessage.add(%"email is not found")
    hasError = true
  if not userParam.hasKey("password") or userParam["password"].getStr().len == 0:
    errorMessage.add(%"password is not found")
    hasError = true
  
  if hasError:
    let body = %*{
      "errors":{
        "body": errorMessage
      }
    }
    return render(Http422, body)


  let name = userParam["username"].getStr()
  let email = userParam["email"].getStr()
  let password = userParam["password"].getStr()

  let usecase = CreateUserUsecase.new()
  let id = usecase.invoke(name, email, password).await

  return render(id)


proc store*(context:Context, params:Params):Future[Response] {.async.} =
  return render("store")


proc edit*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("edit")


proc update*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("update")


proc destroy*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("destroy")
