import ../../../../active_records/rdb
import ../todo_entity
import ../../value_objects

type TodoRepository* = ref object

proc newTodoRepository*():TodoRepository =
  return TodoRepository()
