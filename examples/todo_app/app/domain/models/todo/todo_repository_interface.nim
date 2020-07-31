import json

import ../value_objects
include ../di_container

type ITodoRepository* = ref object

proc newITodoRepository*():ITodoRepository =
  return ITodoRepository()

proc index*(this:ITodoRepository, userId:UserId):seq[JsonNode] =
  return DiContainer.todoRepository().index(userId)

proc show*(this:ITodoRepository, id:TodoId):JsonNode =
  return DiContainer.todoRepository().show(id)

proc insert*(this:ITodoRepository, todo:TodoBody, userId:UserId) =
  DiContainer.todoRepository().insert(todo, userId)

proc destroy*(this:ITodoRepository, id:TodoId) =
  DiContainer.todoRepository().destroy(id)
