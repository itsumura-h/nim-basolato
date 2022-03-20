import asyncdispatch
import todo_value_objects
import todo_entity
import todo_repository_interface
import ../../di_container


type TodoService* = ref object
  repository: ITodoRepository

proc new*(_:type TodoService):TodoService =
  TodoService(
    repository: di.todoRepository
  )

proc getNewTopTodoSort*(self:TodoService, status:Status):Future[Sort]{.async.} =
  let topSortPosition = await self.repository.getCurrentTopSortPosition(status)
  return Sort.new(topSortPosition.get() + 1)

proc swapTodoSort*(self:TodoService, current, next:Todo) {.async.} =
  let currentSort = current.sort
  let nextSort = next.sort
  current.sort = nextSort
  next.sort = currentSort
