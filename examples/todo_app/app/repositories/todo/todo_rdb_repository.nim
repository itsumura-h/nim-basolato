import json, times
import allographer/query_builder
import ../../model/aggregates/todo/todo_entity
import ../../model/aggregates/value_objects


type TodoRdbRepository* = ref object


proc newTodoRepository*():TodoRdbRepository =
  return TodoRdbRepository()

proc index*(this:TodoRdbRepository, userId:UserId):seq[JsonNode] =
  return rdb().table("todos").where("user_id", "=", userId.get).get()

proc show*(this:TodoRdbRepository, id:TodoId):JsonNode =
  return rdb().table("todos").find(id.get)

proc store*(this:TodoRdbRepository, userId:UserId, title:TodoTitle, content:TodoContent) =
  rdb().table("todos").insert(%*{
    "title": title.get(),
    "content": content.get(),
    "is_finished": false,
    "created_at": $(now().utc),
    "updated_at": $(now().utc),
    "user_id": userId.get(),
  })

proc changeStatus*(this:TodoRdbRepository, id:TodoId, status:bool) =
  rdb().table("todos")
    .where("id", "=", id.get())
    .update(%*{
      "is_finished": $status
    })

proc destroy*(this:TodoRdbRepository, id:TodoId) =
  rdb().table("todos").delete(id.get)

proc update*(this:TodoRdbRepository, id:TodoId, title:TodoTitle, content:TodoContent, isFinished:bool) =
  rdb().table("todos")
  .where("id", "=", id.get)
  .update(%*{
    "title": title.get,
    "content": content.get,
    "is_finished": isFinished
  })
