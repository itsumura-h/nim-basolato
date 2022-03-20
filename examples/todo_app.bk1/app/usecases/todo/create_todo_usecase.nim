import asyncdispatch
import ../../di_container
import ../../models/todo/todo_value_objects
import ../../models/todo/todo_entity
import ../../models/todo/todo_service
import ../../models/todo/todo_repository_interface
import ../../models/user/user_value_objects


type CreateTodoUsecase* = ref object
  todoRepository: ITodoRepository
  service: TodoService

proc new*(_:type CreateTodoUsecase):CreateTodoUsecase =
  CreateTodoUsecase(
    todoRepository: di.todoRepository,
    service: TodoService.new()
  )

proc run*(self:CreateTodoUsecase, title, content, createdBy, assignTo, startOn, endOn:string){.async.} =
  let title = Title.new(title)
  let content = Content.new(content)
  let createdBy = UserId.new(createdBy)
  let assignTo = UserId.new(assignTo)
  let startOn = TodoDate.new(startOn)
  let endOn = TodoDate.new(endOn)
  let status = Status.new()
  let sort = await self.service.getNewTopTodoSort(status)
  let todo = Todo.new(title, content, createdBy, assignTo, startOn, endOn, sort)
  await self.todoRepository.insert(todo)
