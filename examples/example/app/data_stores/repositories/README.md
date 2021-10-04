Repositories
===

Repository is a functions to instantiate and persisted `aggregate` model to access file or extrnal web API.  
`Repository` should be created in correspondence with the `aggregate`, a top of `Domain Model`.

```nim
type QueryService* = ref object

proc newQueryService*():QueryService =
  return QueryService()

proc getUser*(this:QueryService: id:UserId):User =

```

```nim
type UserRdbRepository* = ref object

proc newUserRdbRepository*():UserRdbRepository =
  return UserRdbRepository()

proc saveUser*(this:UserRdbRepository, user:User):int =
  return rdb().table("users").insertID(%*{
    "name": $user.name,
    "email": $user.email,
    "password": user.password.getHashed()
  })
```
