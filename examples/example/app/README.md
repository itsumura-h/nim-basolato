Value object
===

Value object difines a behaviour of value.

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

---

Di Container
===
Di Container provide repository implement of Interface. Passing the dependency of the Repository to the Service through the Di Container prevents the Service and Repository from becoming tightly coupled.

```nim
# query service
import ../http/query_service_interface
import ../repositories/query_services/query_service
# user
import aggregates/user/user_repository_interface
import ../repositories/user/user_rdb_repository

type DiContainer* = tuple
  queryService: IQueryService
  userRepository: IUserRepository

proc newDiContainer():DiContainer =
  return (
    queryService: newQueryService().toInterface(),
    userRepository: newUserRdbRepository().toInterface(),
  )

let di* = newDiContainer()
```

In this example, `Repository Interface` call `UserRdbRepository` by resolving as `userRepository`.
