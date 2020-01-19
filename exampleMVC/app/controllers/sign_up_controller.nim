import tables, json, re
# framework
import ../../../src/basolato/controller
# model
import ../models/users
# view
import ../../resources/sign_up/create

type SignUpController = ref object
  user:User

proc newSignUpController*(): SignUpController =
  return SignUpController(
    user: newUser()
  )


proc create*(this:SignUpController): Response =
  return render(createHtml())

proc store*(this:SignUpController, request:Request): Response =
  let params = request.params
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
  if not password.match(re"^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z\d]{8,100}$"):
    errors.add("password", %"A minimum 8 characters password contains a combination of uppercase and lowercase letter and number are required.")
  if errors.len > 0:
    return render(createHtml(name, email, errors))

  # insert
  let uid = this.user.createUser(name, email, password)
  if uid < 0:
    errors.add("general", %getCurrentExceptionMsg())
    return render(createHtml(name, email, errors))

  # session
  let token = sessionStart(uid)
  addSession(token, "uid", $uid)
  addSession(token, "name", name)
  let cookie = genCookie("token", token, daysForward(5))
  return redirect("/posts").setCookie(cookie)
