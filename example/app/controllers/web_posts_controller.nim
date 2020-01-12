import strutils, json, strformat, tables

import ../../../src/basolato/controller

import ../models/posts
import ../models/users

import ../../resources/posts/index
import ../../resources/posts/show
import ../../resources/posts/edit

type WebPostsController = ref object of Controller
  post: Post
  user: User

proc newWebPostsController*(): WebPostsController =
  return WebPostsController(
    post: newPost(),
    user: newUser()
  )


proc index*(this:WebPostsController): Response =
  let posts = this.post.getPosts()
  return render(indexHtml(posts))

proc show*(this:WebPostsController, idArg:string): Response =
  let id = idArg.parseInt
  let post = this.post.getPost(id)
  return render(showHtml(post))

proc edit*(this:WebPostsController, idArg:string): Response =
  let id = idArg.parseInt
  let post = this.post.getPost(id)
  let title = post["title"].getStr
  let body = post["post"].getStr
  let user = post["user"].getStr
  let error = ""
  return render(editHtml(
    id, title, body, user, error
  ))

proc update*(this:WebPostsController, idArg:string, request:Request): Response =
  let id = idArg.parseInt
  let params = request.params
  let title = params["title"]
  let body = params["post"]
    
  try:
    if body.contains("fail"):
      raise newException(Exception, "Post contains word fail")

    this.post.updatePost(id, title, body)
    return redirect(&"/MVCPosts/{id}")
  except Exception:
    let error = getCurrentExceptionMsg()
    let post = this.post.getPost(id)
    let user = post["user"].getStr
    return render(editHtml(
      id, title, body, user, error
    ))