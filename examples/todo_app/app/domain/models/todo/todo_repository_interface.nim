import repositories/todo_rdb_repository
export todo_rdb_repository

# import repositories/todo_json_repository
# export todo_json_repository

type ITodoRepository* = ref object of RootObj
  repository*:TodoRepository

proc newITodoRepository*():TodoRepository =
  return newTodoRepository()
