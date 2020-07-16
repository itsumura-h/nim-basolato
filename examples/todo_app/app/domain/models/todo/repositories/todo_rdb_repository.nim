import json
import allographer/query_builder
import ../todo_entity
import ../../value_objects

type TodoRdbRepository* = ref object

proc newTodoRepository*():TodoRdbRepository =
  return TodoRdbRepository()

proc index*(this:TodoRdbRepository):seq[JsonNode] =
  return RDB().table("todos").get()

proc show*(this:TodoRdbRepository, id:TodoId):JsonNode =
  return RDB().table("todos").find(id.get)

proc insert*(this:TodoRdbRepository, todo:TodoContent) =
  RDB().table("todos").insert(%*{"todo": todo.get()})

proc destroy*(this:TodoRdbRepository, id:TodoId) =
  RDB().table("todos").delete(id.get)
