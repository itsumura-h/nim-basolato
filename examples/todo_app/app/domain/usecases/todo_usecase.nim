import json
import ../models/value_objects
import ../models/todo/todo_service

type TodoUsecase* = ref object

proc newTodoUsecase*():TodoUsecase =
  return TodoUsecase()

proc index*(this:TodoUsecase, userId:int):seq[JsonNode] =
  let userId = newUserId(userId)
  let todoService = newTodoService()
  return todoService.index(userId)

proc show*(this:TodoUsecase, id:int):JsonNode =
  let todoService = newTodoService()
  let id = newTodoId(id)
  return todoService.show(id)

proc insert*(this:TodoUsecase, todo:string, userId:int) =
  let userId = newUserId(userId)
  let todoService = newTodoService()
  let todo = newTodoBody(todo)
  todoService.insert(todo, userId)

proc destroy*(this:TodoUsecase, id:int) =
  let id = newTodoId(id)
  let todoService = newTodoService()
  todoService.destroy(id)