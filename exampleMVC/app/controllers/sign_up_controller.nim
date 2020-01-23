import tables, json, re
# framework
# import ../../../src/basolato/controller
import ../../../src/basolato/private
import ../../../src/basolato/session
import ../../../src/basolato/validation
# middleware
import ../../middleware/custom_validation_middleware
# model
import ../models/users
# view
import ../../resources/sign_up/create

type SignUpController = ref object
  request:Request
  login: Login
  user:User

proc newSignUpController*(request:Request): SignUpController =
  return SignUpController(
    request: request,
    login: initLogin(request),
    user: newUser()
  )


proc create*(this:SignUpController): Response =
  return render(createHtml(this.login))

proc store*(this:SignUpController): Response =
  let name = this.request.params["name"]
  let email = this.request.params["email"]
  let password = this.request.params["password"]
  # validation
  let v = this.request.validate()
            .required(["name", "email", "password"])
            .email("email")
            .unique("email", "users", "email")
            .password("password")
  if v.errors.len > 0:
    return render(createHtml(this.login, name, email, v.errors))
  # insert
  let uid = this.user.createUser(name, email, password)
  if uid < 0:
    v.errors.add("general", %getCurrentExceptionMsg())
    return render(createHtml(this.login, name, email, v.errors))
  # session
  let token = sessionStart(uid)
  addSession(token, "login_name", name)
  let cookie = genCookie("token", token, daysForward(5))
  return redirect("/posts").setCookie(cookie)
