import asyncdispatch, os, asyncfile, tables
export asyncdispatch, tables
import httpbeast
export httpbeast
import
  core/base, core/request, core/response, core/route, core/header,
  core/security
export
  base, request, response, route, header, security


proc asyncHtml*(path:string):Future[string] {.async.} =
  ## Open html file asynchronous.
  ## arg path is relative path from /resources/
  ## .. code-block:: nim
  ##   let indexHtml = await asyncHtml("pages/index.html")
  ##   return render(indexHtml)
  let path = getCurrentDir() & "/resources/" & path
  let f = openAsync(path, fmRead)
  defer: f.close()
  let data = await f.readAll()
  return $data

proc html*(path:string):string =
  ## Open html file.
  ## arg path is relative path from /resources/
  ## .. code-block:: nim
  ##   let indexHtml = html("pages/index.html")
  ##   return render(indexHtml)
  let path = getCurrentDir() & "/resources/" & path
  let f = open(path, fmRead)
  defer: f.close()
  let data = f.readAll()
  return $data
