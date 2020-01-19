import strutils, json, strformat, tables, times
# framework
import ../../../src/basolato/controller
# model
import ../models/posts
# view
import ../../resources/posts/index
import ../../resources/posts/show
import ../../resources/posts/create
import ../../resources/posts/edit

# DI
type PostsController = object of Controller
  post: Post

# constructor
proc newPostsController*(): PostsController =
  return PostsController(
    post: newPost()
  )


proc index*(this:PostsController, request:Request): Response =
  let posts = this.post.getPosts()
  let token = request.getCookie("token")
  let name = token.getSession("name")
  return render(indexHtml(posts, name))


proc show*(this:PostsController, idArg:string): Response =
  let id = idArg.parseInt
  let post = this.post.getPost(id)
  if post.kind == JNull:
    # return render(Http404, "")
    raise newException(Error404, "")
  return render(showHtml(post))


proc create*(this:PostsController): Response =
  return render(createHtml())

proc store*(this:PostsController, request:Request): Response =
  let params = request.params
  let title = params["title"]
  let text = params["text"]

  # varidation check
  var errors = newJObject()
  if title.len == 0:
    errors.add("title", %"This field is required")
  if text.len == 0:
    errors.add("text", %"This field is required")
  if errors.len > 0:
    return render(createHtml(title, text, errors))

  let publishedDate = now().format("yyyy-MM-dd")
  let autherId = 1
  let postId = this.post.store(title, text, publishedDate, autherId)
  return redirect(&"/posts/{postId}")


proc edit*(this:PostsController, idArg:string): Response =
  let id = idArg.parseInt
  let post = this.post.getPost(id)
  let title = post["title"].getStr
  let text = post["text"].getStr
  return render(editHtml(id, title, text))

proc update*(this:PostsController, idArg:string, request:Request): Response =
  let id = idArg.parseInt
  let params = request.params
  let title = params["title"]
  let text = params["text"]

  # validation
  var errors = newJObject()
  if title.len == 0:
    errors.add("title", %"This field is required")
  if text.len == 0:
    errors.add("text", %"This field is required")
  if errors.len > 0:
    return render(editHtml(id, title, text, errors))

  this.post.updatePost(id, title, text)
  return redirect(&"/posts/{id}")
