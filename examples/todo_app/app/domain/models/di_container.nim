import todo/repositories/todo_rdb_repository
import user/repositories/user_rdb_repository
import user/repositories/user_json_repository

type DiContainer* = tuple
  userRepository: UserRdbRepository
  # userRepository: UserJsonRepository
  todoRepository: TodoRdbRepository
