import ../../../../../../../src/basolato/password
import ../../value_objects
import user_entity
import user_repository_interface


type UserService* = ref object
  repository:IUserRepository


proc newUserService*(repository:IUserRepository):UserService =
  return UserService(
    repository:repository
  )

proc getUser*(this:UserService, email:UserEmail, password:Password):User =
  let user =  this.repository.getUser(email)
  if isMatchPassword($password, $(user.hashedPassword())):
    return user
  else:
    raise newException(Exception, "user not found")

proc isMatchPassword*(this:UserService, password:Password, hashedPassword:HashedPassword):bool =
  return isMatchPassword($password, $hashedPassword)
