import ../value_objects

type Todo* = ref object
  id:TodoId
  content: ToDoContent
  isFinished:bool

proc newTodo*(id:TodoId, content:TodoContent, isFinished:bool):Todo =
  return Todo(
    id: id,
    content: content,
    isFinished: isFinished
  )
