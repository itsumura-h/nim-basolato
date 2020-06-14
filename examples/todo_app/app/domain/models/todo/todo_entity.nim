import ../value_objects

type Todo* = ref object

proc newTodo*():Todo =
  return Todo()
