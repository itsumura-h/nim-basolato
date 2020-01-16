import strutils, json, strformat, tables, times
# 3rd party
import ../../../src/basolato/controller
# model
import ../models/posts
# view
# import ../../resources/posts/base
import ../../resources/posts/index
import ../../resources/posts/show
import ../../resources/posts/create
import ../../resources/posts/edit

# DI
type WebBlogController = object of Controller
  post: Post

# constructor
proc newWebBlogController*(): WebBlogController =
  return WebBlogController(
    post: newPost()
  )


proc index*(this:WebBlogController): Response =
  let posts = this.post.getPosts()
  return render(indexHtml(posts))


proc show*(this:WebBlogController, idArg:string): Response =
  let id = idArg.parseInt
  let post = this.post.getPost(id)
  if post.kind == JNull:
    # return render(Http404, "")
    raise newException(Error404, "")
  return render(showHtml(post))


proc create*(this:WebBlogController): Response =
  return render(createHtml())

proc store*(this:WebBlogController, request:Request): Response =
  echo "=== store"
  let params = request.params
  let title = params["title"]
  let text = params["text"]
  let publishedDate = now().format("yyyy-MM-dd")
  let autherId = 1
  echo title
  echo text
  echo publishedDate
  let postId = this.post.store(title, text, publishedDate, autherId)
  return redirect(&"/WebBlog/{postId}")


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