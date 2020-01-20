import tables, json, re
# framework
# import ../../../src/basolato/controller
import ../../../src/basolato/private
import ../../../src/basolato/session
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
  let params = this.request.params
  let name = params["name"]
  let email = params["email"]
  let password = params["password"]

  # validation
  var errors = newJObject()
  if name.len == 0:
    errors.add("name", %"This is required field")
  if email.len == 0:
    errors.add("email", %"This is required field")
  elif not email.match(re"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"):
    errors.add("email", %"Invalid form of email")
  elif this.user.isEmailDuplication(email):
    errors.add("email", %"email should be unique")
  if not password.match(re"^[a-zA-Z\d]{8,100}$"):
    errors.add("password", %"A minimum 8 characters password contains a combination of uppercase and lowercase letter and number are required.")
  if errors.len > 0:
    return render(createHtml(this.login, name, email, errors))

  # insert
  let uid = this.user.createUser(name, email, password)
  if uid < 0:
    errors.add("general", %getCurrentExceptionMsg())
    return render(createHtml(this.login, name, email, errors))

  # session
  let token = sessionStart(uid)
  addSession(token, "login_name", name)
  let cookie = genCookie("token", token, daysForward(5))
  return redirect("/posts").setCookie(cookie)
