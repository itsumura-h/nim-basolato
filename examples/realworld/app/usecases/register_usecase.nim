import std/asyncdispatch
import std/options
import ../errors
import ../di_container
import ../models/aggregates/user/user_repository_interface
import ../models/aggregates/user/user_entity
import ../models/vo/user_id
import ../models/vo/user_name
import ../models/vo/email
import ../models/vo/password


type RegisterUsecase*  = object
  repository:IUserRepository

proc new*(_:type RegisterUsecase):RegisterUsecase =
  return RegisterUsecase(
    repository:di.userRepository
  )


proc invoke*(self:RegisterUsecase, name, email, password:string):Future[tuple[id:string, name:string]] {.async.} =
  let name = UserName.new(name)
  let email = Email.new(email)
  let password = Password.new(password)

  let loginUserOpt = self.repository.getUserByEmail(email).await
  if loginUserOpt.isSome():
    raise newException(DomainError, "User already exists")

  let user = DraftUser.new(name, email, password)

  self.repository.create(user).await

  let resp = (id:user.id.value, name:user.name.value)
  return resp
