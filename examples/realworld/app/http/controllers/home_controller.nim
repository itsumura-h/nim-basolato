import std/asyncdispatch
import std/json
# framework
import basolato/controller
import ../views/pages/home/home_page


proc homePage*(context:Context):Future[Response] {.async.} =
  let page = homePage().await
  return render(page)
