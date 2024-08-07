import std/asyncdispatch
import std/asyncfile
import std/os
import core/base; export base
import core/response; export response
import core/route; export route
import core/header; export header
import core/security/cookie; export cookie
import core/security/session; export session
import core/security/context; export context
import ./core/params; export params
import ./core/templates

when defined(httpbeast) or defined(httpx):
  import core/libservers/nostd/request; export request
else:
  import core/libservers/std/request; export request


proc asyncHtml*(path:string):Future[Component] {.async.} =
  ## Open html file asynchronous.
  ## arg path is relative path from app/http/views
  ## .. code-block:: nim
  ##   let indexHtml = asyncHtml("pages/index.html").await
  ##   return render(indexHtml)
  let path = getCurrentDir() / "app/http/views" / path
  let f = openAsync(path, fmRead)
  defer: f.close()
  let data = f.readAll().await
  let component = Component.new()
  component.add(data)
  return component


proc html*(path:string):Component =
  ## Open html file.
  ## arg path is relative path from app/http/views
  ## .. code-block:: nim
  ##   let indexHtml = html("pages/index.html")
  ##   return render(indexHtml)
  let path = getCurrentDir() / "app/http/views" / path
  let f = open(path, fmRead)
  defer: f.close()
  let data = f.readAll()
  let component = Component.new()
  component.add(data)
  return component
