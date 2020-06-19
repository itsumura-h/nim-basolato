from strutils import parseInt
# framework
import ../../../../src/basolato/controller
# view
import ../../resources/pages/todo_view


type TodoController* = ref object of Controller

proc newTodoController*(request:Request):TodoController =
  return TodoController.newController(request)


proc index*(this:TodoController):Response =
  return render(this.view.todoView())

proc show*(this:TodoController, id:string):Response =
  let id = id.parseInt
  return render("show")

proc create*(this:TodoController):Response =
  return render("create")

proc store*(this:TodoController):Response =
  return render("store")

proc edit*(this:TodoController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:TodoController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:TodoController, id:string):Response =
  let id = id.parseInt
  return render("destroy")
