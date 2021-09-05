import basolato/password
import user_value_objects


type User* = ref object
  id:UserId
  name:UserName
  email:Email
  password:Password

func new*(typ:type User, id:UserId, name:UserName, email:Email, password:Password):User =
  return typ(
    id:id,
    name:name,
    email:email,
    password:password,
  )

proc id*(self:User):UserId =
  return self.id

proc name*(self:User):UserName =
  return self.name

proc email*(self:User):Email =
  return self.email

proc password*(self:User):Password =
  return self.password
