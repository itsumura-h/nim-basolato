import std/asyncdispatch
import ../errors
import ../di_container
import ../models/aggregates/user/user_repository_interface
import ../models/aggregates/user/user_service
import ../models/aggregates/user/user_entity
import ../models/vo/user_id
import ../models/vo/user_name
import ../models/vo/email
import ../models/vo/password

type CreateUserUsecase*  = object
  repository:IUserRepository

proc new*(_:type CreateUserUsecase):CreateUserUsecase =
  return CreateUserUsecase(
    repository:di.userRepository
  )

proc invoke*(self:CreateUserUsecase, userName, email, password:string):Future[string] {.async.} =
  let userName = UserName.new(userName)
  let email = Email.new(email)
  let password = Password.new(password)

  let service = UserService.new()
  if not service.isEmailUnique(email).await:
    raise newException(DomainError, "email is deprecated")

  let user = DraftUser.new(userName, email, password)
  let id = self.repository.create(user).await
  return id.value
