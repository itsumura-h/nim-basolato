import std/asyncdispatch
import std/options
import ../errors
import ../di_container
import ../models/aggregates/user/user_repository_interface
import ../models/aggregates/user/user_service
import ../models/aggregates/user/user_entity
import ../models/vo/user_id
import ../models/vo/email
import ../models/vo/password

type LoginUsecase*  = object
  repository:IUserRepository

proc new*(_:type LoginUsecase):LoginUsecase =
  return LoginUsecase(
    repository:di.userRepository
  )

proc invoke*(self:LoginUsecase, email, password:string):Future[(string, string)] {.async.} =
  let email = Email.new(email)
  let password = Password.new(password)

  let loginUserOpt = self.repository.getUserByEmail(email).await
  if not loginUserOpt.isSome():
    raise newException(DomainError, "User not found")

  let user = loginUserOpt.get

  let service = UserService.new()
  if not service.isMatchPassword(password, user.password):
    raise newException(DomainError, "Invalid password")

  let resp = (user.id.value, user.name.value)
  return resp
