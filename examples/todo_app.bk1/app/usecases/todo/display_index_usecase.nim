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
  let master = await self.query.getMasterData()
  let todoList = await self.query.todoList()
  let transaction = IndexListViewModel.new(todoList)
  return %*{
    "master": master,
    "transaction": transaction
  }
