import json
from strutils import parseInt
# framework
import ../../../../src/basolato/controller
# usecase
import ../domain/usecases/todo_usecase

type ApiTodoController* = ref object of Controller

proc newApiTodoController*(request:Request):ApiTodoController =
  return ApiTodoController.newController(request)


proc index*(this:ApiTodoController):Response =
  let userId = this.auth.get("user_id").parseInt
  let todoUsecase = newTodoUsecase()
  let todos = todoUsecase.index(userId)
  return render(%*todos)

proc show*(this:ApiTodoController, id:string):Response =
  let id = id.parseInt
  return render("show")

proc create*(this:ApiTodoController):Response =
  return render("create")

proc store*(this:ApiTodoController):Response =
  return render("store")

proc edit*(this:ApiTodoController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:ApiTodoController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:ApiTodoController, id:string):Response =
  let id = id.parseInt
  return render("destroy")
