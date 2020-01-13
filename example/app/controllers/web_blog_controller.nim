import strutils, json, strformat, tables

import ../../../src/basolato/controller
import allographer/query_builder

import ../models/posts
import ../models/users

import ../../resources/posts/index
import ../../resources/posts/show
import ../../resources/posts/edit

type WebBlogController = ref object of Controller
  post: Post
  user: User

proc newWebBlogController*(): WebBlogController =
  return WebBlogController(
    post: newPost(),
    user: newUser()
  )


proc index*(this:WebBlogController): Response =
  # let posts = this.post.getPosts()
  let posts = RDB().table("posts")
                .select("posts.id", "posts.title", "posts.text", "users.name as auther")
                .join("users", "users.id", "=", "posts.auther_id")
                .get()
  return render(indexHtml(posts))

proc show*(this:WebBlogController, idArg:string): Response =
  let id = idArg.parseInt
  let post = this.post.getPost(id)
  return render(showHtml(post))

proc edit*(this:WebBlogController, idArg:string): Response =
  let id = idArg.parseInt
  let post = this.post.getPost(id)
  let title = post["title"].getStr
  let text = post["text"].getStr
  let auther = post["auther"].getStr
  let error = ""
  return render(editHtml(
    id, title, text, auther, error
  ))

proc update*(this:WebBlogController, idArg:string, request:Request): Response =
  let id = idArg.parseInt
  let params = request.params
  let title = params["title"]
  let text = params["text"]
    
  try:
    if text.contains("fail"):
      raise newException(Exception, "Post contains word fail")

    this.post.updatePost(id, title, text)
    return redirect(&"/MVCPosts/{id}")
  except Exception:
    let error = getCurrentExceptionMsg()
    let post = this.post.getPost(id)
    let auther = post["auther"].getStr
    return render(editHtml(
      id, title, text, auther, error
    ))