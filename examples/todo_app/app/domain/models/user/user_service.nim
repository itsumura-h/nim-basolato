import options
import ../value_objects
import user_entity
import user_repository_interface

type UserService* = ref object
  repository:IUserRepository

proc newUserService*(userRepositoryInterface:IUserRepository):UserService =
  return UserService(
    repository:userRepositoryInterface
  )


proc print*(this:UserService) =
  this.repository.print()

proc isExists*(this:UserService, user:User):bool =
  var duplicateUser = this.repository.find(user.email.get())
  if isSome(duplicateUser):
    return true
  else:
    return false

proc save*(this:UserService, user:User):int =
  return this.repository.save(user)

