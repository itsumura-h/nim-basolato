import json
import allographer/query_builder
import ../todo_entity
import ../../value_objects

type TodoRdbRepository* = ref object

proc newTodoRepository*():TodoRdbRepository =
  return TodoRdbRepository()

proc index*(this:TodoRdbRepository, userId:UserId):seq[JsonNode] =
  return RDB().table("todos").where("user_id", "=", userId.get).get()

proc show*(this:TodoRdbRepository, id:TodoId):JsonNode =
  return RDB().table("todos").find(id.get)

proc insert*(this:TodoRdbRepository, todo:TodoBody, userId:UserId) =
  RDB().table("todos").insert(%*{
    "todo": todo.get(),
    "user_id": userId.get()
  })

proc destroy*(this:TodoRdbRepository, id:TodoId) =
  RDB().table("todos").delete(id.get)
