Value object
===

Value object difines a behaviour of value.

## Example
```nim
type UserName* = ref object
  value:string

proc newUserName*(value:string):UserName =
  if isEmptyOrWhitespace(value):
    raise newException(Exception, "Name can't be blank")
  if value.len == 0:
    raise newException(Exception, "Name can't be blank")
  if value.len > 11:
    raise newException(Exception, "Name should be shorter than 10")
  return UserName(value:value)

proc get*(this:UserName):string =
  return this.value
```

## Usase
```nim
let userName = newUserName("") # Error raised
let userName = newUserName("abcdefghij") # Error raised
let userName = newUserName("John") # Success
echo username.get() # >> "John"
```

---

Domain Model
===

Domain model consists `Entity`, `Service` , `Repository` and `Repository impl`.

```
├── user
│   ├── repositories
│   │   ├── user_json_repository.nim
│   │   └── user_rdb_repository.nim
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

## Repository
Repository is a functions to access database or file.

```nim
type UserRepository* = ref object

proc newUserRepository*():UserRepository =
  return UserRepository()


proc show*(this:UserRepository, user:User):JsonNode =
  return newUser().find(user.getId)

proc store*(this:UserRepository, user:User):int =
  newUser().insertID(%*{
    "name": user.getName(),
    "email": user.getEmail(),
    "password": user.getHashedPassword()
  })
```