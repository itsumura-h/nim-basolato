import ../../../../../../src/basolato/password
import ../value_objects
import user_entity
import user_repository_interface


type UserService* = ref object
  repository:IUserRepository


proc newUserService*():UserService =
  return UserService(
    repository:newIUserRepository()
  )

proc getUser*(this:UserService, email:UserEmail, password:Password):User =
  let user =  this.repository.getUser(email)
  if isMatchPassword(password.get, user.hashedPassword().get):
    return user
  else:
    raise newException(Exception, "user not found")

proc isMatchPassword*(this:UserService, password:Password, hashedPassword:HashedPassword):bool =
  return isMatchPassword(password.get, hashedPassword.get)
