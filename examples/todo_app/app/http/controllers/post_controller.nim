import json, strutils, strformat
# framework
import ../../../../../src/basolato/controller
# model
import ../query_service_interface
import ../../model/usecases/post_usecase
# view
import ../views/pages/post/index_view
import ../views/pages/post/show_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  let id = await(auth.get("id")).parseInt
  let queryService = newIQueryService()
  let posts = queryService.getPostsByUserId(id)
  return render(await indexView(auth, posts))

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let queryService = newIQueryService()
  let post = queryService.getPostByUserId(id)
  let auth = await newAuth(request)
  return render(await showView(auth, post))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let title = params.getStr("title")
  let content = params.getStr("content")
  let auth = await newAuth(request)
  try:
    let userId = await(auth.get("id")).parseInt
    let usecase = newPostUsecase()
    usecase.store(userId, title, content)
    return redirect("/")
  except:
    await auth.setFlash("error", getCurrentExceptionMsg())
    return redirect("/")

proc changeStatus*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let status = params.getBool("status")
  let usecase = newPostUsecase()
  usecase.changeStatus(id, status)
  return redirect("/")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let usecase = newPostUsecase()
  usecase.destroy(id)
  return redirect("/")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let title = params.getStr("title")
  let content = params.getStr("content")
  let isFinished = params.getBool("is_finished")
  let auth = await newAuth(request)
  try:
    let usecase = newPostUsecase()
    usecase.update(id, title, content, isFinished)
    return redirect("/")
  except:
    await auth.setFlash("error", getCurrentExceptionMsg())
    let post = %*{"title": title, "content": content, "is_finished": isFinished}
    return render(await showView(auth, post))
