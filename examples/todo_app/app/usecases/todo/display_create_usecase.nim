import asyncdispatch, json
import ../../di_container
import todo_query_interface


type DisplayCreateUsecase* = ref object
  query: ITodoQuery

proc new*(_:type DisplayCreateUsecase):DisplayCreateUsecase =
  DisplayCreateUsecase(
    query: di.todoQuery
  )

proc run*(self:DisplayCreateUsecase):Future[JsonNode]{.async.} =
  let statuses = self.query.getStatuses().await
  let users = self.query.getUsers().await
  return %*{
    "statuses": statuses,
    "users": users,
  }
