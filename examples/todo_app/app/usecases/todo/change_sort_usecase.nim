import asyncdispatch, options
import ../../di_container
import ../../models/todo/todo_value_objects
import ../../models/todo/todo_entity
import ../../models/todo/todo_repository_interface

type ChangeSortUsecase* = ref object
  repository:ITodoRepository

proc new*(_:type ChangeSortUsecase):ChangeSortUsecase =
  ChangeSortUsecase(
    repository: di.todoRepository
  )

proc run*(self:ChangeSortUsecase, id:string, currentSort:int, nextId:string, nextSort:int) {.async.} =
  let id = TodoId.new(id)
  let currentSort = Sort.new(currentSort)
  let nextId = TodoId.new(nextId)
  let nextSort = Sort.new(nextSort)

  let currentTodo = await self.repository.getTodoById(id)
  currentTodo.sort = nextSort
  await self.repository.save(currentTodo)

  let nextTodo = await self.repository.getTodoById(nextId)
  nextTodo.sort = currentSort
  await self.repository.save(nextTodo)
