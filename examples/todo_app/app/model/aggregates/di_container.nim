import ../../repositories/user/user_rdb_repository
import ../../repositories/todo/todo_rdb_repository

type DiContainer* = tuple
  userRepository: UserRdbRepository
  todoRepository: TodoRdbRepository
