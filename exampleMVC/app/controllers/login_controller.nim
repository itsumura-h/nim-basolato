# import ../../../src/basolato/controller
import ../../../src/basolato/private
import ../../../src/basolato/session
import ../models/users

type LoginController = ref object
  request: Request
  login: Login
  user: User

proc newLoginController*(request:Request): LoginController =
  return LoginController(
    request: request,
    login: initLogin(request),
    user: newUser()
  )

proc create*(this: LoginController): Response =
  discard

proc store*(this: LoginController): Response =
  discard

proc destroy*(this: LoginController): Response =
  this.login.sessionDestroy()
  return redirect("/posts")
