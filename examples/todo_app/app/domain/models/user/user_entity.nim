import ../value_objects


type User* = ref object
  id:UserId
  name:UserName
  email:UserEmail
  hashedPassword:HashedPassword

proc newUser*(name:UserName, email:UserEmail, hashedPassword:HashedPassword):User =
  result = new User
  result.name = name
  result.email = email
  result.hashedPassword = hashedPassword

proc newUser*(email:UserEmail, hashedPassword:HashedPassword):User =
  result = new User
  result.email = email
  result.hashedPassword = hashedPassword

proc newUser*(id:UserId, name:UserName, email:UserEmail, hashedPassword:HashedPassword):User =
  result = new User
  result.id = id
  result.name = name
  result.email = email
  result.hashedPassword = hashedPassword

proc id*(this:User):UserId =
  return this.id

proc name*(this:User):UserName =
  return this.name

proc email*(this:User):UserEmail =
  return this.email

proc hashedPassword*(this:User):HashedPassword =
  return this.hashedPassword
