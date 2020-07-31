import ../value_objects

type Todo* = ref object
  id:TodoId
  content: TodoBody
  isFinished:bool

proc newTodo*(id:TodoId, content:TodoBody, isFinished:bool):Todo =
  return Todo(
    id: id,
    content: content,
    isFinished: isFinished
  )
