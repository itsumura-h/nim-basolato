import asyncdispatch
import todo_value_objects
import todo_entity


type ITodoRepository* = tuple
  getCurrentTopSortPosition: proc(status:Status):Future[Sort]
  insert: proc(todo:Todo):Future[void]
