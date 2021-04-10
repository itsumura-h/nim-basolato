import value_objects


type User* = ref object
  id:UserId
  name:UserName
  email:UserEmail
  hashedPassword:HashedPassword

proc newUser*(id:UserId, name:UserName, email:UserEmail, hashedPassword:HashedPassword):User =
  result = new User
  result.id = id
  result.name = name
  result.email = email
  result.hashedPassword = hashedPassword

proc id*(self:User):UserId =
  return self.id

proc name*(self:User):UserName =
  return self.name

proc email*(self:User):UserEmail =
  return self.email

proc hashedPassword*(self:User):HashedPassword =
  return self.hashedPassword
