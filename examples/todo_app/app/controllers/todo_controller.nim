import json
from strutils import parseInt
# framework
import ../../../../src/basolato/controller
# middleware
import ../middlewares/controller_middlewares
# usecase
import ../domain/usecases/todo_usecase
# view
import ../../resources/pages/todo_view
import ../../resources/pages/todo_detail_view


type TodoController* = ref object of Controller

proc newTodoController*(request:Request):TodoController =
  # middleware
  hasSessionId(request)
  return TodoController.newController(request)


proc index*(this:TodoController):Response =
  let todoUsecase = newTodoUsecase()
  let todos = todoUsecase.getTodos()
  return render(this.view.todoView(todos))

proc show*(this:TodoController, id:string):Response =
  let id = id.parseInt
  let todoUsecase = newTodoUsecase()
  let todo = todoUsecase.show(id)
  return render(this.view.todoDetailView(todo))

proc create*(this:TodoController):Response =
  return render("create")

proc store*(this:TodoController):Response =
  let todo = this.request.params["todo"]
  let todoUsecase = newTodoUsecase()
  todoUsecase.insert(todo)
  return redirect("/")

proc edit*(this:TodoController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:TodoController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:TodoController, id:string):Response =
  let id = id.parseInt
  let todoUsecase = newTodoUsecase()
  todoUsecase.destroy(id)
  return redirect("/")
