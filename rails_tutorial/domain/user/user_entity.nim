import bcrypt
import ../value_objects

type User* = ref object
  id:Id
  name:UserName
  email:Email
  password:Password

proc getId*(this:User):int =
  return this.id.get

proc getName*(this:User):string =
  return this.name.get

proc getEmail*(this:User):string =
  return this.email.get

proc getPassword*(this:User):string =
  return this.password.get

proc getHashedPassword*(this:User):string =
  return this.password.getHashed


# =============================================================================
proc newUser*(id:Id):User =
  return User(id:id)

proc newUser*(name:UserName, email:Email, password:Password):User =
  return User(
    name:name,
    email:email,
    password:password
  )

proc newUser*(email:Email, password:Password):User =
  # Login
  return User(
    email:email,
    password:password
  )

# =============================================================================
proc isMatchPassword*(this:User, hashedPasswod:string):bool =
  let password = this.getPassword()
  return compare(hashedPasswod, password)
