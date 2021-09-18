# user
import models/user/user_repository_interface
import data_stores/repositories/user/user_repository
# todo
import usecases/todo/todo_query_service_interface
import data_stores/query_services/todo/todo_query_service

type DiContainer* = tuple
  userRepository: IUserRepository
  todoQueryService: ITodoQueryService

proc newDiContainer():DiContainer =
  return (
    userRepository: UserRepository.new().toInterface(),
    todoQueryService: newTodoQueryService().toInterface(),
  )

let di* = newDiContainer()
