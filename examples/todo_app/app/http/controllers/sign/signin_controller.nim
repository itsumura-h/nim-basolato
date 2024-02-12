import json, strutils
# framework
import ../../../../../../src/basolato/controller
import ../../../../../../src/basolato/request_validation
import ../../../usecases/sign/signin_usecase
import ../../views/pages/sign/signin_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let (params, errors) = context.getValidationResult().await
  return render(signinView(params, errors).await)

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  v.required("email")
  v.required("password")
  v.email("email")
  if v.hasErrors():
    context.storeValidationResult(v).await
    return redirect("/signin")

  let email = params.getStr("email")
  let password = params.getStr("password")
  try:
    let usecase = SigninUsecase.new()
    let user = usecase.run(email, password).await
    echo "=== user ",user
    context.login().await
    context.set("id", user["id"].getStr).await
    context.set("name", user["name"].getStr).await
    context.set("auth", $user["auth"].getInt).await
    return redirect("/todo")
  except:
    echo "=== except"
    echo getCurrentExceptionMsg()
    v.errors.add("error", getCurrentExceptionMsg().splitLines()[0])
    context.storeValidationResult(v).await
    return redirect("/signin")

proc delete*(context:Context, params:Params):Future[Response] {.async.} =
  context.logout().await
  return redirect("/signin")
