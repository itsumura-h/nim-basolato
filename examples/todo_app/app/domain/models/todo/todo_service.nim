import json
import ../value_objects
import todo_entity
import repositories/todo_rdb_repository
import todo_repository_interface

type TodoService* = ref object
  repository:TodoRepository

proc newTodoService*():TodoService =
  return TodoService(
    repository:newITodoRepository()
  )

proc getTodos*(this:TodoService):seq[JsonNode] =
  return this.repository.getTodos()

proc show*(this:TodoService, id:TodoId):JsonNode =
  return this.repository.show(id)

proc insert*(this:TodoService, todo:TodoContent) =
  this.repository.insert(todo)

proc destroy*(this:TodoService, id:TodoId) =
  this.repository.destroy(id)