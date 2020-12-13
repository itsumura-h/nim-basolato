import json
import ../value_objects
include ../di_container


type ITodoRepository* = ref object


proc newITodoRepository*():ITodoRepository =
  return newITodoRepository()

proc index*(this:ITodoRepository, userId:UserId):seq[JsonNode] =
  return DiContainer.todoRepository().index(userId)

proc show*(this:ITodoRepository, id:TodoId):JsonNode =
  return DiContainer.todoRepository().show(id)

proc store*(this:ITodoRepository, userId:UserId,  title:TodoTitle, content:TodoContent) =
  DiContainer.todoRepository().store(userId, title, content)

proc changeStatus*(this:ITodoRepository, id:TodoId, status:bool) =
  DiContainer.todoRepository().changeStatus(id, status)

proc destroy*(this:ITodoRepository, id:TodoId) =
  DiContainer.todoRepository().destroy(id)

proc update*(this:ITodoRepository, id:TodoId, title:TodoTitle, content:TodoContent, isFinished:bool) =
  DiContainer.todoRepository().update(id, title, content, isFinished)
