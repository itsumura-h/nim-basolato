import json
import ../value_objects
import todo_entity
import todo_repository_interface

type TodoService* = ref object
  repository:ITodoRepository

proc newTodoService*():TodoService =
  return TodoService(
    repository: newITodoRepository()
  )

proc index*(this:TodoService, userId:UserId):seq[JsonNode] =
  return this.repository.index(userId)

proc show*(this:TodoService, id:TodoId):JsonNode =
  return this.repository.show(id)

proc insert*(this:TodoService, todo:TodoBody, userId:UserId) =
  this.repository.insert(todo, userId)

proc destroy*(this:TodoService, id:TodoId) =
  this.repository.destroy(id)
