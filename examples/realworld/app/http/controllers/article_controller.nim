import std/asyncdispatch
# framework
import basolato/controller
import ../views/pages/article/article_page


proc show*(context:Context):Future[Response] {.async.} =
  let page = articlePage().await
  return render(page)
