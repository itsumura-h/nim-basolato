import json, strutils, strformat
# framework
import ../../../../src/basolato/controller
# domain
import ../domain/usecases/todo_usecase
# view
import ../../resources/pages/todo/index_view
import ../../resources/pages/todo/show_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  let userId = await(auth.get("id")).parseInt
  let usecase = newTodoUsecase()
  let todos = usecase.index(userId)
  return render(await indexView(auth, todos))

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let usecase = newTodoUsecase()
  let post = usecase.show(id)
  let auth = await newAuth(request)
  return render(await showView(auth, post))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let title = params.getStr("title")
  let content = params.getStr("content")
  let auth = await newAuth(request)
  try:
    let userId = await(auth.get("id")).parseInt
    let usecase = newTodoUsecase()
    usecase.store(userId, title, content)
    return redirect("/")
  except:
    await auth.setFlash("error", getCurrentExceptionMsg())
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
  let auth = await newAuth(request)
  try:
    let usecase = newTodoUsecase()
    usecase.update(id, title, content, isFinished)
    return redirect("/")
  except:
    await auth.setFlash("error", getCurrentExceptionMsg())
    let post = %*{"title": title, "content": content, "is_finished": isFinished}
    return render(await showView(auth, post))
