import json
import ../../../../active_records/rdb
import ../todo_entity
import ../../value_objects

type TodoRepository* = ref object

proc newTodoRepository*():TodoRepository =
  return TodoRepository()

proc getTodos*(this:TodoRepository):seq[JsonNode] =
  return newTodoTable().get()

proc show*(this:TodoRepository, id:TodoId):JsonNode =
  return newTodoTable().find(id.get)

proc insert*(this:TodoRepository, todo:TodoContent) =
  newTodoTable().insert(%*{"todo": todo.get()})

proc destroy*(this:TodoRepository, id:TodoId) =
  newTodoTable().delete(id.get)
