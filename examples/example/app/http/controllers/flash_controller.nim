import std/asyncdispatch
import std/json
# framework
import ../../../../../src/basolato/controller
import ../views/pages/flash/flash_page


proc flashPage*(context:Context):Future[Response] {.async.} =
  let page = flashPageView(context).await
  return render(page)


proc store*(context:Context):Future[Response] {.async.} =
  await context.setFlash("msg", "This is flash message")
  return redirect("/sample/flash")
