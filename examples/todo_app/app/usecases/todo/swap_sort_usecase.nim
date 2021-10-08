import asyncdispatch
import ../../di_container
import ../../models/todo/todo_value_objects
import ../../models/todo/todo_entity
import ../../models/todo/todo_repository_interface
import ../../models/todo/todo_service

type SwapSortUsecase* = ref object
  repository:ITodoRepository
  service: TodoService

proc new*(_:type SwapSortUsecase):SwapSortUsecase =
  SwapSortUsecase(
    repository: di.todoRepository,
    service: TodoService.new()
  )

proc run*(self:SwapSortUsecase, id, nextId:string) {.async.} =
  let id = TodoId.new(id)
  let nextId = TodoId.new(nextId)
  let currentTodo = await self.repository.getTodoById(id)
  let nextTodo = await self.repository.getTodoById(nextId)
  await self.service.swapTodoSort(currentTodo, nextTodo)
  await self.repository.save(currentTodo)
  await self.repository.save(nextTodo)
