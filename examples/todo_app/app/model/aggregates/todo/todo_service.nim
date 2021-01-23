import ../value_objects
import todo_entity
import todo_repository_interface


type TodoService* = ref object
  repository:ITodoRepository


proc newTodoService*():TodoService =
  return TodoService(
    repository:newITodoRepository()
  )
