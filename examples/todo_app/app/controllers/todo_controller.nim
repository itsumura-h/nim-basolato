import json, strutils, strformat
# framework
import ../../../../src/basolato/controller
import ../domain/usecases/todo_usecase
import ../../resources/pages/todo/index_view
import ../../resources/pages/todo/show_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  let userId = auth.get("id").parseInt
  let usecase = newTodoUsecase()
  let todos = usecase.index(userId)
  return render(indexView(auth, todos))

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let usecase = newTodoUsecase()
  let post = usecase.show(id)
  let auth = newAuth(request)
  return render(showView(auth, post))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let title = params.getStr("title")
  let content = params.getStr("content")
  let auth = newAuth(request)
  try:
    let userId = auth.get("id").parseInt
    let usecase = newTodoUsecase()
    usecase.store(userId, title, content)
    return redirect("/")
  except:
    auth.setFlash("error", getCurrentExceptionMsg())
    return redirect("/")

proc changeStatus*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let status = params.getBool("status")
  let usecase = newTodoUsecase()
  usecase.changeStatus(id, status)
  return redirect("/")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let usecase = newTodoUsecase()
  usecase.destroy(id)
  return redirect("/")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let title = params.getStr("title")
  let content = params.getStr("content")
  let isFinished = params.getBool("is_finished")
  let auth = newAuth(request)
  try:
    let usecase = newTodoUsecase()
    usecase.update(id, title, content, isFinished)
    return redirect(&"/{id}")
  except:
    auth.setFlash("error", getCurrentExceptionMsg())
    let post = %*{"title": title, "content": content, "is_finished": isFinished}
    return render(showView(auth, post))
