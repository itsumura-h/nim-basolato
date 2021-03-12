import json, strutils, options
# framework
import ../../../../../../src/basolato/controller
# model
import ../../di_container
import ../../repositories/query_services/query_service
import ../../core/usecases/post_usecase
# view
import ../views/pages/post/index_view
import ../views/pages/post/show_view


proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  let id = await(auth.get("id")).parseInt
  let posts = di.queryService.getPostsByUserId(id)
  return render(await indexView(auth, posts))

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let post = di.queryService.getPostByUserId(id)
  if not post.isSome:
    raise newException(Error404, "Post not found")
  let auth = await newAuth(request)
  return render(await showView(auth, post.get))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let title = params.getStr("title")
  let content = params.getStr("content")
  let auth = await newAuth(request)
  let userId = await(auth.get("id")).parseInt
  try:
    let repository = di.postRepository
    let usecase = newPostUsecase(repository)
    usecase.store(userId, title, content)
    return redirect("/")
  except:
    await auth.setFlash("error", getCurrentExceptionMsg())
    return redirect("/")

proc changeStatus*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let status = params.getBool("status")
  let repository = di.postRepository
  let usecase = newPostUsecase(repository)
  usecase.changeStatus(id, status)
  return redirect("/")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let repository = di.postRepository
  let usecase = newPostUsecase(repository)
  usecase.destroy(id)
  return redirect("/")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let title = params.getStr("title")
  let content = params.getStr("content")
  let isFinished = params.getBool("is_finished")
  let auth = await newAuth(request)
  try:
    let repository = di.postRepository
    let usecase = newPostUsecase(repository)
    usecase.update(id, title, content, isFinished)
    return redirect("/")
  except:
    await auth.setFlash("error", getCurrentExceptionMsg())
    let post = %*{"title": title, "content": content, "is_finished": isFinished}
    return render(await showView(auth, post))

# ==================== API ====================

proc indexApi*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  let id = await(auth.get("id")).parseInt
  let posts = di.queryService.getPostsByUserId(id)
  return render(%*{"name":await auth.get("name"), "posts":posts})

proc showApi*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let post = di.queryService.getPostByUserId(id)
  if not post.isSome:
    return render(Http404, %*{"error": "Post not found"})
  let auth = await newAuth(request)
  return render(%*{
    "title": post.get["title"].getStr,
    "content": post.get["content"].getStr,
    "isFinished": post.get["is_finished"].getBool
  })

proc storeApi*(request:Request, params:Params):Future[Response] {.async.} =
  let title = params.getStr("title")
  let content = params.getStr("content")
  let auth = await newAuth(request)
  let userId = await(auth.get("id")).parseInt
  try:
    let repository = di.postRepository
    let usecase = newPostUsecase(repository)
    usecase.store(userId, title, content)
    return render("")
  except:
    return render(Http422, %*{"error": getCurrentExceptionMsg()})

proc changeStatusApi*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let status = params.getBool("status")
  let repository = di.postRepository
  let usecase = newPostUsecase(repository)
  usecase.changeStatus(id, status)
  return render("")

proc destroyApi*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let repository = di.postRepository
  let usecase = newPostUsecase(repository)
  usecase.destroy(id)
  return render("")

proc updateApi*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let title = params.getStr("title")
  let content = params.getStr("content")
  let isFinished = params.getBool("isFinished")
  let auth = await newAuth(request)
  try:
    let repository = di.postRepository
    let usecase = newPostUsecase(repository)
    usecase.update(id, title, content, isFinished)
    return render("")
  except:
    return render(Http422, %*{"error": getCurrentExceptionMsg()})
