Repositories
===

Repository is a functions to `insert`, `update` and `delete` database, file or extrnal web API.  
To fetch data, You should use not `repository` but `query service`.
`Repository` should be created in correspondence with the `aggregate`.

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
