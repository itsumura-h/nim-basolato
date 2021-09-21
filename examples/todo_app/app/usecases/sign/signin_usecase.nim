import asyncdispatch, json, options
import ../../di_container
import ../../models/user/user_value_objects
import ../../models/user/user_entity
import ../../models/user/user_repository_interface
import ../../models/user/user_service

type SigninUsecase* = ref object
  repository: IUserRepository
  service: UserService

proc new*(typ:type SigninUsecase):SigninUsecase =
  typ(
    repository: di.userRepository,
    service: UserService.new(di.userRepository)
  )

proc run*(self:SigninUsecase, email, password:string):Future[JsonNode] {.async.} =
  let email = Email.new(email)
  let userOpt = await self.repository.getUserByEmail(email)
  if not userOpt.isSome():
    raise newException(Exception, "user is not found")
  let user = userOpt.get
  let password = Password.new(password)
  if self.service.isMatchPassword(password, user):
    return %*{
      "id": $user.id,
      "name": $user.name
    }
  else:
    raise newException(Exception, "password is not match")
