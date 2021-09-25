import user_value_objects


type DraftUser* = ref object
  name:UserName
  email:Email
  password:Password

proc name*(self:DraftUser):UserName = self.name
proc email*(self:DraftUser):Email = self.email
proc password*(self:DraftUser):Password = self.password

func new*(typ:type DraftUser, name:UserName, email:Email, password:Password):DraftUser =
  return typ(
    name:name,
    email:email,
    password:password,
  )


type User* = ref object
  id:UserId
  name:UserName
  email:Email
  password:Password
  auth: Auth

proc id*(self:User):UserId = self.id
proc name*(self:User):UserName = self.name
proc email*(self:User):Email = self.email
proc password*(self:User):Password = self.password
proc auth*(self:User):Auth = self.auth

func new*(typ:type User, id:UserId, name:UserName, email:Email, password:Password,
          auth:Auth):User =
  return typ(
    id:id,
    name:name,
    email:email,
    password:password,
    auth:auth
  )
