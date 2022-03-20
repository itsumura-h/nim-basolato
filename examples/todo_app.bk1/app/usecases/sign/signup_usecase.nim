import asyncdispatch, options
import ../../di_container
import ../../models/user/user_value_objects
import ../../models/user/user_entity
import ../../models/user/user_repository_interface


type SignupUsecase* = ref object
  repository:IUserRepository

proc new*(typ:type SignupUsecase):SignupUsecase =
  typ(
    repository:di.userRepository
  )

proc run*(self:SignupUsecase, name, email, password:string):Future[int]{.async.} =
  let name = UserName.new(name)
  let email = Email.new(email)
  let password = Password.new(password)
  let user = DraftUser.new(name, email, password)
  let existsUser = await self.repository.getUserByEmail(email)
  if existsUser.isSome():
    raise newException(Exception, "email is already userd")
  let id = await self.repository.save(user)
  return id
