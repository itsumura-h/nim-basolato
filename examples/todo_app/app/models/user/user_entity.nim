import user_value_objects


type DraftUser* = ref object
  name*: UserName
  email*: Email
  password*: Password

func new*(typ:type DraftUser, name:UserName, email:Email, password:Password):DraftUser =
  return typ(
    name:name,
    email:email,
    password:password,
  )


type User* = ref object
  id*: UserId
  name*: UserName
  email*: Email
  password*: Password
  auth*: Auth

func new*(typ:type User, id:UserId, name:UserName, email:Email, password:Password,
          auth:Auth):User =
  return typ(
    id:id,
    name:name,
    email:email,
    password:password,
    auth:auth
  )
