import json

import ../value_objects
include ../di_container

type ITodoRepository* = ref object

proc newITodoRepository*():ITodoRepository =
  return ITodoRepository()

proc index*(this:ITodoRepository):seq[JsonNode] =
  return DiContainer.todoRepository().index()

proc show*(this:ITodoRepository, id:TodoId):JsonNode =
  return DiContainer.todoRepository().show(id)

proc  insert*(this:ITodoRepository, todo:TodoContent) =
  DiContainer.todoRepository().insert(todo)

proc destroy*(this:ITodoRepository, id:TodoId) =
  DiContainer.todoRepository().destroy(id)
