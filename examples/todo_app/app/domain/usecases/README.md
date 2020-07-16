Usecases
===

The duty of Usecase is
- the difinition of bussiness logic.
- It calls `value object`, `Entity` and `application service`.

## Example

```nim
import json
import ..//models/value_objects
import ../models/user/user_entity
import ../models/user/user_repository_interface
import ../models/user/user_service

type UsersUsecase* = ref object
  repository:UserRepository

proc newUsersUsecase*():UsersUsecase =
  return UsersUsecase(repository:newIUserRepository())

proc store*(this:UsersUsecase, name="", email="", password=""):int =
  let name = newUserName(name)
  let email = newEmail(email)
  let password = newPassword(password)
  let user = newUser(name=name, email=email, password=password)
  let id = this.repository.store(user)
  let userId = newId(id).get()
  return userId
```
