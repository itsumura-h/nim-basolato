import asyncdispatch, json, options
import interface_implements
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/todo/todo_value_objects
import ../../../models/todo/todo_entity
import ../../../models/todo/todo_repository_interface
import ../../../models/user/user_value_objects


type TodoRepository* = ref object

func new*(_:type TodoRepository):TodoRepository =
  TodoRepository()

implements TodoRepository, ITodoRepository:
  proc getCurrentTopSortPosition(self:TodoRepository, status:Status):Future[Sort]{.async.} =
    let topTodoOpt = await rdb.table("todo")
                      .where("status_id", "=", status.get())
                      .orderBy("sort", Desc)
                      .first()
    if not topTodoOpt.isSome():
      raise newException(Exception, "todo is not found")
    let topTodo = topTodoOpt.get()
    return Sort.new( topTodo["sort"].getInt )

  proc insert(self:TodoRepository, todo:Todo):Future[void] {.async.} =
    await rdb.table("todo").insert(%*{
      "id": $todo.id,
      "title": $todo.title,
      "content_md": $todo.content,
      "content_html": todo.content.toHtml(),
      "created_by": $todo.createdBy,
      "assign_to": $todo.assignTo,
      "start_on": $todo.startOn,
      "end_on": $todo.endOn,
      "status_id": todo.status.get(),
      "sort": todo.sort.get()
    })
