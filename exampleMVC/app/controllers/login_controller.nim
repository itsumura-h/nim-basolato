import json
# 3rd party
import bcrypt
# framework
import ../../../src/basolato/controller
import ../../../src/basolato/validation
# middleware
import ../../middleware/custom_validation_middleware
# model
import ../models/users
# view
import ../../resources/login/create


type LoginController = ref object
  request: Request
  auth: Auth
  user: User

proc newLoginController*(request:Request): LoginController =
  return LoginController(
    request: request,
    auth: initAuth(request),
    user: newUser()
  )

proc create*(this: LoginController): Response =
  return render(createHtml(this.auth))

proc store*(this: LoginController): Response =
  let email = this.request.params["email"]
  let password = this.request.params["password"]
  # validation
  let v = this.request.validate()
            .required(["email", "password"])
            .email("email")
            .password("password")
            .checkPassword("password")
  # check error
  if v.errors.len > 0:
    return render(createHtml(this.auth, email, v.errors))
  # get user info
  let user = this.user.getUserByEmail(email)
  let uid = user["id"].getInt
  let name = user["name"].getStr
  # create sesstion
  let cookie = sessionStart(uid)
                .add("login_name", name)
                .setCookie(daysForward(5))
  return redirect("/posts").setCookie(cookie)

proc destroy*(this: LoginController): Response =
  this.auth.sessionDestroy()
  return redirect("/posts").deleteCookie("token")
