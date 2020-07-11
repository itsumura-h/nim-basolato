import json
import ../models/value_objects
import ../models/todo/todo_service

type TodoUsecase* = ref object

proc newTodoUsecase*():TodoUsecase =
  return TodoUsecase()

proc getTodos*(this:TodoUsecase):seq[JsonNode] =
  let todoService = newTodoService()
  return todoService.getTodos()

proc show*(this:TodoUsecase, id:int):JsonNode =
  let todoService = newTodoService()
  let id = newTodoId(id)
  return todoService.show(id)

proc insert*(this:TodoUsecase, todo:string) =
  let todoService = newTodoService()
  let todo = newTodoContent(todo)
  todoService.insert(todo)

proc destroy*(this:TodoUsecase, id:int) =
  let id = newTodoId(id)
  let todoService = newTodoService()
  todoService.destroy(id)