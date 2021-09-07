import ../../../../../src/basolato/password
import user_value_objects
import user_entity
import user_repository_interface


type UserService* = ref object
  repository: IUserRepository

func new*(typ:type UserService, repository:IUserRepository):UserService =
  typ(
    repository: repository
  )

proc isMatchPassword*(self:UserService, password:Password, user:User):bool =
  return isMatchPassword($password, $user.password)
