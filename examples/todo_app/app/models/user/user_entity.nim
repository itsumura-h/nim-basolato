import user_value_objects


type DraftUser* = ref object
  name:UserName
  email:Email
  password:Password

func new*(typ:type DraftUser, name:UserName, email:Email, password:Password):DraftUser =
  return typ(
    name:name,
    email:email,
    password:password,
  )

proc name*(self:DraftUser):UserName =
  return self.name

proc email*(self:DraftUser):Email =
  return self.email

proc password*(self:DraftUser):Password =
  return self.password


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
