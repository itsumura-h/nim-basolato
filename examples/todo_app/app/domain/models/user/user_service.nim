import options
import ../../../../../../src/basolato/password
import ../value_objects
import user_entity
import repositories/user_repository
import ../di_container

type UserService* = ref object
  repository:UserRepository

proc newUserService*(userRepository:UserRepository):UserService =
  return UserService(
    repository: userRepository
  )


proc isExists*(this:UserService, user:User):bool =
  let duplicateUser = this.repository.find(user.email)
  if isSome(duplicateUser):
    return true
  else:
    return false

proc save*(this:UserService, user:User):int =
  return this.repository.save(user)

proc find*(this:UserService, email:Email):User =
  let user = this.repository.find(email)
  if isSome(user):
    return user.get()
  else:
    raise newException(CatchableError, "user cannot be found")

proc checkPasswordValid*(this:UserService, user:User, password:Password) =
  if not isMatchPassword(password.get(), user.hashedPassword.get()):
    raise newException(CatchableError, "Password is not match")
