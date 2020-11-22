import json
import ../models/value_objects
import ../models/todo/todo_repository_interface

type TodoUsecase* = ref object
  repository: ITodoRepository

proc newTodoUsecase*():TodoUsecase =
  return TodoUsecase()

proc index*(this:TodoUsecase, userId:int):seq[JsonNode] =
  let userId = newUserId(userId)
  return this.repository.index(userId)

proc show*(this:TodoUsecase, id:int):JsonNode =
  return this.repository.show(id)

proc store*(this:TodoUsecase, userId:int, title, content:string) =
  let userId = newUserId(userId)
  let title = newTodoTitle(title)
  let content = newTodoDetail(content)
  this.repository.store(userId, title, content)

proc changeStatus*(this:TodoUsecase, id:int, status:bool) =
  let id = newTodoId(id)
  this.repository.changeStatus(id, status)

proc destroy*(this:TodoUsecase, id:int) =
  let id = newTodoId(id)
  this.repository.destroy(id)
