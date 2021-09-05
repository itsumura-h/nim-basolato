# user
import models/user/user_repository_interface
import data_stores/repositories/user/user_repository

type DiContainer* = tuple
  userRepository: IUserRepository

proc newDiContainer():DiContainer =
  return (
    userRepository: UserRepository.new().toInterface(),
  )

let di* = newDiContainer()
