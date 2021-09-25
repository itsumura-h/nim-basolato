import json, strutils
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/request_validation
# view
import ../views/pages/todo/index_view
import ../views/pages/todo/create_view
# usecase
import ../../usecases/todo/display_index_usecase
import ../../usecases/todo/display_create_usecase
import ../../usecases/todo/create_todo_usecase

proc toppage*(context:Context, params:Params):Future[Response] {.async.} =
  return redirect("/todo")

proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let loginUser = %*{
    "id": await context.get("id"),
    "name": await context.get("name"),
    "auth": await(context.get("auth")).parseInt,
  }
  let usecase = DisplayIndexUsecase.new()
  let data = await usecase.run()
  return render(indexView(loginUser, data))

proc show*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("show")

proc create*(context:Context, params:Params):Future[Response] {.async.} =
  let usecase = DisplayCreateUsecase.new()
  let data = await usecase.run()
  let (params, errors) = await context.getValidationResult()
  return render(createView(params, errors, data))

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  v.required("title")
  v.required("content")
  v.required("assign_to", "assign")
  v.required("start_on", "start on"); v.date("start_on", "yyyy-MM-dd", "start on")
  v.required("end_on", "due date"); v.date("end_on", "yyyy-MM-dd", "due date")
  v.afterOrEqual("end_on", "start_on", "yyyy-MM-dd", "due date")
  if v.hasErrors:
    await context.storeValidationResult(v)
    return redirect("/todo/create")
  let
    title = params.getStr("title")
    content = params.getStr("content")
    createdBy = await context.get("id")
    assignTo = params.getStr("assign_to")
    startOn = params.getStr("start_on")
    endOn = params.getStr("end_on")
    usecase = CreateTodoUsecase.new()
  await usecase.run(title, content, createdBy, assignTo, startOn, endOn)
  return redirect("/todo")

proc edit*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("edit")

proc update*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("update")

proc destroy*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("destroy")
