import asyncdispatch
import todo_value_objects
import todo_entity


type ITodoRepository* = tuple
  getTodoById: proc(id:TodoId):Future[Todo]
  getCurrentTopSortPosition: proc(status:Status):Future[Sort]
  insert: proc(todo:Todo):Future[void]
  save: proc(todo:Todo):Future[void]
