import ../value_objects
import ../../../../../../src/basolato/password

type User* = ref object
  id*:UserId
  name*:UserName
  email*:Email
  password*:Password
  hashedPassword*:HashedPassword

proc newUser*(id:UserId, name:UserName, email:Email):User =
  return User(
    id:id,
    name:name,
    email:email
  )

proc newDraftUser*(name:UserName, email:Email, password:Password):User =
  return User(
    name:name,
    email:email,
    password:password,
    hashedPassword:password.getHashed()
  )


proc check*(this:User):bool =
  return isMatchPassword(this.password.get(), this.hashedPassword.get())
