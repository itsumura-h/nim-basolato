import ../value_objects
import ../../../../../../src/basolato/password

type User* = ref object
  name:UserName
  email:Email
  password:Password
  hashedPassword:HashedPassword

proc newDraftUser*(name:UserName, email:Email, password:Password):User =
  return User(
    name:name,
    email:email,
    password:password,
    hashedPassword:password.getHashed()
  )


proc check*(this:User):bool =
  return isMatchPassword(this.password.get(), this.hashedPassword.get())
