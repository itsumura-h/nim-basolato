import json, strutils, options, strformat
# framework
import ../../../../../../src/basolato/controller
import ../../../../../../src/basolato/request_validation
# model
import ../../di_container
import ../../repositories/query_services/query_service
import ../../core/usecases/post_usecase
# view
import ../views/pages/post/index_view
import ../views/pages/post/show_view

proc rule(v:RequestValidation) =
  v.required("title"); v.minStr("title", 3);
  v.required("content"); v.minStr("content", 5);

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  let id = await(client.get("id")).parseInt
  let posts = di.queryService.getPostsByUserId(id)
  return render(await indexView(client, posts))

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let post = di.queryService.getPostById(id)
  if not post.isSome:
    raise newException(Error404, "Post not found")
  let client = await newClient(request)
  return render(await showView(client, post.get))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  let client = await newClient(request)

  v.rule()
  if v.hasErrors:
    await client.storeValidationResult(v)
    return redirect(request.path)

  let title = params.getStr("title")
  let content = params.getStr("content")
  let userId = await(client.get("id")).parseInt
  try:
    let repository = di.postRepository
    let usecase = newPostUsecase(repository)
    usecase.store(userId, title, content)
  except:
    v.errors.add("core", getCurrentExceptionMsg())
    await client.storeValidationResult(v)

  return redirect(request.path)

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
  let v = newRequestValidation(params)
  let client = await newClient(request)

  v.rule()
  if v.hasErrors:
    await client.storeValidationResult(v)
    return redirect(request.url.path)

  let id = params.getInt("id")
  let title = params.getStr("title")
  let content = params.getStr("content")
  let isFinished = params.getBool("is_finished")
  try:
    let repository = di.postRepository
    let usecase = newPostUsecase(repository)
    usecase.update(id, title, content, isFinished)
    return redirect("/")
  except:
    v.errors.add("core", getCurrentExceptionMsg())
    await client.storeValidationResult(v)
    return redirect(request.path)

# ==================== API ====================

proc indexApi*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  let id = await(client.get("id")).parseInt
  let posts = di.queryService.getPostsByUserId(id)
  return render(%*{"name":await client.get("name"), "posts":posts})

proc showApi*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let post = di.queryService.getPostById(id)
  if not post.isSome:
    return render(Http404, %*{"error": "Post not found"})
  let client = await newClient(request)
  return render(%*{
    "title": post.get["title"].getStr,
    "content": post.get["content"].getStr,
    "isFinished": post.get["is_finished"].getBool
  })

proc storeApi*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  v.rule()
  if v.hasErrors:
    return render(Http422, %*{"params": params, "errors": v.errors})

  let title = params.getStr("title")
  let content = params.getStr("content")
  let client = await newClient(request)
  let userId = await(client.get("id")).parseInt
  try:
    let repository = di.postRepository
    let usecase = newPostUsecase(repository)
    usecase.store(userId, title, content)
    return render("")
  except:
    return render(Http422, %*{"params": params, "errors": v.errors})

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
  let v = newRequestValidation(params)
  v.rule()
  if v.hasErrors:
    return render(Http422, %*{"params":params, "errors":v.errors})

  let id = params.getInt("id")
  let title = params.getStr("title")
  let content = params.getStr("content")
  let isFinished = params.getBool("isFinished")
  let client = await newClient(request)
  try:
    let repository = di.postRepository
    let usecase = newPostUsecase(repository)
    usecase.update(id, title, content, isFinished)
    return render("")
  except:
    v.errors.add("core", getCurrentExceptionMsg())
    return render(Http422, %*{"params": params, "errors": v.errors})
