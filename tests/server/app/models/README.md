Usecase
===

Usecase create instance of `Value Object`, `Entity` and `Service` and call these methods to realize bussiness logic.

```nim
let userName = newUserName("") # Error raised
let userName = newUserName("abcdefghij") # Error raised
let userName = newUserName("John") # Success
echo username.get() # >> "John"
```

---

Domain Model
===

Domain model consists `Entity`, `Service` , `RepositoryInterface` and `Repository`.  
You can create domain model by command `ducere make model {domain name}`

```
├── user
│   ├── user_entity.nim
│   ├── user_repository_interface.nim
│   └── user_service.nim
└── value_objects.nim
```

## Entity
Entity is object which is a substance of business logic. In a simple application it is the same of a database table, but in a complex application it is represented as multiple tables joined together.

```nim
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
  # signin
  if not email.isUnique():
    raise newException(Exception, "email should unique")

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
```

## Repository Interface
The Repository Interface prevents the Repository knowledge from leaking to Service by executing the Repository's methods through the Di Container.

```nim
include ../di_container

type IUserRepository* = ref object

proc newIUserRepository*():IUserRepository =
  return IUserRepository()

proc find*(this:IUserRepository, email:Email):Option[User] =
  return di.userRepository().find(email)

proc save*(this:IUserRepository, user:User):int =
  return di.userRepository().save(user)
```

## Repository
Repository is a functions to access database, file or extrnal web API.

```nim
type UserRdbRepository* = ref object

proc newUserRdbRepository*():UserRdbRepository =
  return UserRdbRepository()


proc show*(this:UserRdbRepository, user:User):JsonNode =
  return newUser().find(user.getId)

proc store*(this:UserRdbRepository, user:User):int =
  newUser().insertID(%*{
    "name": user.getName(),
    "email": user.getEmail(),
    "password": user.getHashedPassword()
  })
```