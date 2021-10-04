import json, asyncdispatch


type ITodoQuery* = tuple
  getMasterData: proc():Future[JsonNode]
  todoList: proc():Future[seq[JsonNode]]


type IndexListViewModel* = ref object
  todo*: seq[JsonNode]
  doing*: seq[JsonNode]
  done*: seq[JsonNode]

proc new*(typ: type IndexListViewModel, data:seq[JsonNode]):IndexListViewModel =
  var todo, doing, done:seq[JsonNode] = @[]
  for row in data:
    if row["status"].getStr == "todo":
      todo.add(row)
    elif row["status"].getStr == "doing":
      doing.add(row)
    elif row["status"].getStr == "done":
      done.add(row)

  return typ(
    todo: todo,
    doing: doing,
    done: done
  )