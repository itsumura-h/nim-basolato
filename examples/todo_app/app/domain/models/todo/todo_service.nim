import todo_entity
import todo_repository_interface

type TodoService* = ref object
  repository:TodoRepository

proc newTodoService*():TodoService =
  return TodoService(
    repository:newITodoRepository()
  )
