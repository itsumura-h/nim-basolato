import strutils, json, strformat, tables, times
# framework
import ../../../src/basolato/controller
import ../../../src/basolato/validation
# model
import ../models/posts
# view
import ../../resources/posts/index
import ../../resources/posts/show
import ../../resources/posts/create
import ../../resources/posts/edit

# DI
type PostsController* = ref object
  request*: Request
  login*: Login
  post: Post
  

# constructor
proc newPostsController*(request:Request): PostsController =
  return PostsController(
    request: request,
    login: initLogin(request),
    post: newPost()
  )


proc index*(this:PostsController): Response =
  let posts = this.post.getPosts()
  return render(indexHtml(this.login, posts))


proc show*(this:PostsController, idArg:string): Response =
  let id = idArg.parseInt
  let post = this.post.getPost(id)
  if post.kind == JNull:
    raise newException(Error404, "")
  return render(showHtml(this.login, post))


proc create*(this:PostsController): Response =
  return render(createHtml(this.login))

proc store*(this:PostsController): Response =
  let title = this.request.params["title"]
  let text = this.request.params["text"]
  # varidation check
  let v = this.request.validate()
            .required(["title", "text"])
  if v.errors.len > 0:
    return render(createHtml(this.login, title, text, v.errors))

  let publishedDate = now().format("yyyy-MM-dd")
  let autherId = this.login.uid
  let postId = this.post.store(title, text, publishedDate, autherId)
  return redirect(&"/posts/{postId}")


proc edit*(this:PostsController, idArg:string): Response =
  let id = idArg.parseInt
  let post = this.post.getPost(id)
  let title = post["title"].getStr
  let text = post["text"].getStr
  return render(editHtml(this.login, id, title, text))

proc update*(this:PostsController, idArg:string): Response =
  let id = idArg.parseInt
  let title = this.request.params["title"]
  let text = this.request.params["text"]

  # validation
  let v = this.request.validate()
            .required(["title", "text"])
  if v.errors.len > 0:
    return render(editHtml(this.login, id, title, text, v.errors))

  this.post.updatePost(id, title, text)
  return redirect(&"/posts/{id}")
