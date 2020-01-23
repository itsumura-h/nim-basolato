import times, json, re, os, strutils
# 3rd party
import bcrypt
# import ../../../src/basolato/controller
import ../../../src/basolato/private
import ../../../src/basolato/session
import ../../../src/basolato/validation
# middleware
import ../../middleware/custom_validation_middleware
# model
import ../models/users
# view
import ../../resources/login/create

const SALT = getEnv("SALT").string

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
  return render(createHtml(this.login))

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
    return render(createHtml(this.login, email, v.errors))
  # create sesstion
  let user = this.user.getUserByEmail(email)
  let uid = user["id"].getInt
  let token = sessionStart(uid)
  let name = user["name"].getStr
  addSession(token, "login_name", name)
  let cookie = genCookie("token", token, daysForward(5))
  return redirect("/posts").setCookie(cookie)

proc destroy*(this: LoginController): Response =
  this.login.sessionDestroy()
  return redirect("/posts").deleteCookie("token")
