# user
import models/user/user_repository_interface
import data_stores/repositories/user/user_repository
# todo
import usecases/todo/todo_query_interface
import data_stores/query_services/todo/todo_query
# todo
import models/todo/todo_repository_interface
import data_stores/repositories/todo/todo_repository

type DiContainer* = tuple
  userRepository: IUserRepository
  todoQuery: ITodoQuery
  todoRepository: ITodoRepository

proc newDiContainer():DiContainer =
  return (
    userRepository: UserRepository.new().toInterface(),
    todoQuery: TodoQuery.new().toInterface(),
    todoRepository: TodoRepository.new().toInterface(),
  )

let di* = newDiContainer()
