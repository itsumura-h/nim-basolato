import json, strutils
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/request_validation
# view
import ../views/pages/todo/index/index_view
import ../views/pages/todo/index/index_view_model
import ../views/pages/todo/create/create_view
# usecase
import ../../usecases/todo/display_index_usecase
import ../../usecases/todo/display_create_usecase
import ../../usecases/todo/create_todo_usecase
import ../../usecases/todo/swap_sort_usecase


proc redirectTodo*(context:Context, params:Params):Future[Response] {.async.} =
  return redirect("/todo")

proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let loginUser = %*{
    "id": context.get("id").await,
    "name": context.get("name").await,
    "auth": context.get("auth").await.parseInt,
  }
  return render(indexView(loginUser).await)

proc show*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getStr("id")
  return render("show")

proc create*(context:Context, params:Params):Future[Response] {.async.} =
  let usecase = DisplayCreateUsecase.new()
  let data = usecase.run().await
  let (params, errors) = context.getValidationResult().await
  return render(createView(params, errors, data))

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
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
    createdBy = context.get("id").await
    assignTo = params.getStr("assign_to")
    startOn = params.getStr("start_on")
    endOn = params.getStr("end_on")
    usecase = CreateTodoUsecase.new()
  await usecase.run(title, content, createdBy, assignTo, startOn, endOn)
  return redirect("/todo")

proc changeSort*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getStr("id")
  let nextId = params.getStr("next_id")
  let usecase = SwapSortUsecase.new()
  await usecase.run(id, nextId)
  return redirect("/todo")

proc changeStatus*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getStr("id")
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
