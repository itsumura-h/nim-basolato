import strutils, json, strformat, tables, times
# framework
import ../../../src/basolato/controller
import ../../../src/basolato/request_validation
# model
import ../models/posts
# view
import ../../resources/posts/index
import ../../resources/posts/show
import ../../resources/posts/create
import ../../resources/posts/edit

# DI
type PostsController* = ref object of Controller
  post: Post

# constructor
proc newPostsController*(request:Request): PostsController =
  var instance = PostsController.newController(request)
  instance.post = newPost()
  return instance


proc index*(this:PostsController): Response =
  let posts = this.post.getPosts()
  return render(indexHtml(this.auth, posts))
            .setAuth(this.auth) # update expire


proc show*(this:PostsController, id:string): Response =
  block:
    let id = id.parseInt
    let post = this.post.getPost(id)
    if post.kind == JNull:
      raise newException(Error404, "")
    return render(showHtml(this.auth, post))


proc create*(this:PostsController): Response =
  return render(createHtml(this.auth))


proc store*(this:PostsController): Response =
  let title = this.request.params["title"]
  let text = this.request.params["text"]
  # varidation check
  let v = this.request.validate()
            .required(["title", "text"])
  if v.errors.len > 0:
    return render(createHtml(this.auth, title, text, v.errors))

  let publishedDate = now().format("yyyy-MM-dd")
  let autherId = this.auth.get("uid")
  let postId = this.post.store(title, text, publishedDate, autherId)
  return redirect(&"/posts/{postId}")


proc edit*(this:PostsController, id:string): Response =
  block:
    let id = id.parseInt
    let post = this.post.getPost(id)
    # login check
    if this.auth.get("uid") != $post["auther_id"].getInt:
      raise newException(Error302, "/posts")
    # get params
    let title = post["title"].getStr
    let text = post["text"].getStr
    return render(editHtml(this.auth, id, title, text))


proc update*(this:PostsController, id:string): Response =
  block:
    let id = id.parseInt
    let title = this.request.params["title"]
    let text = this.request.params["text"]
    # validation
    let v = this.request.validate()
              .required(["title", "text"])
    if v.errors.len > 0:
      return render(editHtml(this.auth, id, title, text, v.errors))

    this.post.updatePost(id, title, text)
    return redirect(&"/posts/{id}")


proc destroy*(this:PostsController, id:string): Response =
  block:
    let id = id.parseInt
    this.post.deletePost(id)
    return redirect(&"/posts")
