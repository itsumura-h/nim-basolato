import std/asyncdispatch
# framework
import basolato/controller
import ../views/pages/home/home_page


proc homePage*(context: Context): Future[Response] {.async.} =
  let page = homePageView(context).await
  render(page)
