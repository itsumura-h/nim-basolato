import ../../../../../../../src/basolato/password
import user_value_objects
import user_entity
import user_repository_interface


type UserService* = ref object
  repository:IUserRepository


proc newUserService*(repository:IUserRepository):UserService =
  return UserService(
    repository:repository
  )

proc getUser*(self:UserService, email:UserEmail, password:Password):User =
  let user =  self.repository.getUser(email)
  if isMatchPassword($password, $(user.hashedPassword())):
    return user
  else:
    raise newException(Exception, "user not found")

proc isMatchPassword*(self:UserService, password:Password, hashedPassword:HashedPassword):bool =
  return isMatchPassword($password, $hashedPassword)
