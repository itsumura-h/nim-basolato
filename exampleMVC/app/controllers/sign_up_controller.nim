import tables, json
# framework
import ../../../src/basolato/controller
import ../../../src/basolato/validation
# model
import ../models/users
# view
import ../../resources/sign_up/create

type SignUpController = ref object of Controller
  user:User

proc newSignUpController*(request:Request): SignUpController =
  var instance = SignUpController.newController(request)
  instance.user = newUser()
  return instance


proc create*(this:SignUpController): Response =
  return render(createHtml(this.auth))

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
    return render(createHtml(this.auth, name, email, v.errors))
  # insert
  let uid = this.user.createUser(name, email, password)
  if uid < 0:
    v.errors.add("general", %getCurrentExceptionMsg())
    return render(createHtml(this.auth, name, email, v.errors))
  # session
  let cookie = sessionStart(uid)
                .add("login_name", name)
                .setCookie(daysForward(5))
  return redirect("/posts").setCookie(cookie)
