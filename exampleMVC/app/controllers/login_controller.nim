# import ../../../src/basolato/controller
import ../../../src/basolato/private
import ../models/users

type LoginController = ref object
  user: User

proc newLoginController*(): LoginController =
  return LoginController(
    user: newUser()
  )

proc create*(this: LoginController): Response =
  discard

proc store*(this: LoginController): Response =
  discard

proc destroy*(this: LoginController): Response =
  discard
