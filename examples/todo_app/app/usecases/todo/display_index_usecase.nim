import json, asyncdispatch
import ../../di_container
import todo_query_interface


type DisplayIndexUsecase* = ref object
  query: ITodoQuery

proc new*(typ:type DisplayIndexUsecase):DisplayIndexUsecase =
  DisplayIndexUsecase(
    query: di.todoQuery
  )

proc run*(self:DisplayIndexUsecase):Future[JsonNode]{.async.} =
  let statuses = await self.query.getStatuses()
  let users = await self.query.getUsers()
  let tasks = await self.query.getTodoList()
  return %*{
    "statuses": statuses,
    "users": users,
    "tasks": tasks
  }
