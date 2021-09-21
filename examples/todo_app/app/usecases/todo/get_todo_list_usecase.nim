import json, asyncdispatch
import ../../di_container
import todo_query_interface


type GetTodoListUsecase* = ref object
  query: ITodoQuery

proc new*(typ:type GetTodoListUsecase):GetTodoListUsecase =
  typ(
    query: di.todoQuery
  )

proc run*(self:GetTodoListUsecase):Future[JsonNode]{.async.} =
  let master = await self.query.indexMasterData()
  let todoList = await self.query.todoList()
  let transaction = IndexListViewModel.new(todoList)
  return %*{
    "master": master,
    "transaction": transaction
  }
