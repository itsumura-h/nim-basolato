import asyncdispatch, asynchttpserver, os, asyncfile, tables
export asyncdispatch, asynchttpserver, tables

import
  core/base, core/request, core/response, core/route, core/header,
  core/security/cookie, core/security/session, core/security/context
export
  base, request, response, route, header, cookie, session, context


proc asyncHtml*(path:string):Future[string] {.async.} =
  ## Open html file asynchronous.
  ## arg path is relative path from app/http/views
  ## .. code-block:: nim
  ##   let indexHtml = await asyncHtml("pages/index.html")
  ##   return render(indexHtml)
  let path = getCurrentDir() / "app/http/views" / path
  let f = openAsync(path, fmRead)
  defer: f.close()
  let data = await f.readAll()
  return $data

proc html*(path:string):string =
  ## Open html file.
  ## arg path is relative path from app/http/views
  ## .. code-block:: nim
  ##   let indexHtml = html("pages/index.html")
  ##   return render(indexHtml)
  let path = getCurrentDir() / "app/http/views" / path
  let f = open(path, fmRead)
  defer: f.close()
  let data = f.readAll()
  return $data
