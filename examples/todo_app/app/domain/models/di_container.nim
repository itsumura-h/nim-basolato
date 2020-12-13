import user/repositories/user_rdb_repository
import todo/repositories/todo_rdb_repository

type DiContainer* = tuple
  userRepository: UserRdbRepository
  todoRepository: TodoRdbRepository
