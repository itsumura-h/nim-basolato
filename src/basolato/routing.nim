import json, tables, macros, strformat, httpcore
import jester
import htmlgen
import base, logger

export jester, base


template route*(rArg: Response) =
  block:
    let r = rArg
    var newHeaders = r.headers
    case r.responseType:
    of String:
      newHeaders.add(("Content-Type", "text/html;charset=utf-8"))
    of Json:
      newHeaders.add(("Content-Type", "application/json"))
      r.bodyString = $(r.bodyJson)
    of Redirect:
      newHeaders.add(("Location", r.url))
      resp r.status, newHeaders, ""

    if r.status == Http200:
      logger($r.status & "  " & request.path)
      logger($newHeaders)
    elif r.status.is4xx() or r.status.is5xx():
      echoErrorMsg($r.status &  &"  {request.ip}  {request.path}")
      echoErrorMsg($newHeaders)
    resp r.status, newHeaders, r.bodyString

# =============================================================================

proc joinHeader(t1, t2:openArray[tuple[key, value: string]]):seq[tuple[key, value: string]] =
  ## join t1 and t2. t2 can override t1 if both have same key
  ##
  ## .. code-block:: nim
  ##    var t1 = [("key1", "val1"),("key2", "val2")]
  ##
  ##    var t2 = [("key1", "val1++"),("key3", "val3")]
  ##
  ##    var t3 = joinHeader(t1, t2)
  ##
  ##    echo t3
  ##    >> [
  ##      ("key1", "val1++"),
  ##      ("key2", "val2"),
  ##      ("key3", "val3"),
  ##    ]
  ##
  var t1_1 = t1.toOrderedTable
  let t2_1 = t2.toOrderedTable
  for key, val in t2_1.pairs:
    t1_1[key] = val
  var t3: seq[tuple[key, value:string]]
  for key, val in t1_1.pairs:
    t3.add((key, val))
  return t3


template route*(rArg:Response,
                middleareHeaders:openArray[tuple[key, value: string]]) =
  block:
    let r = rArg
    var newHeaders = joinHeader(middleareHeaders, r.headers)
    case r.responseType:
    of String:
      newHeaders.add(("Content-Type", "text/html;charset=utf-8"))
    of Json:
      newHeaders.add(("Content-Type", "application/json"))
      r.bodyString = $(r.bodyJson)
    of Redirect:
      newHeaders.add(("Location", r.url))
      echo newHeaders
      echo $r.status
      resp r.status, newHeaders, ""

    if r.status == Http200:
      logger($r.status & "  " & request.path)
      logger($newHeaders)
    elif r.status.is4xx() or r.status.is5xx():
      echoErrorMsg($r.status &  &"  {request.ip}  {request.path}")
      echoErrorMsg($newHeaders)
    resp r.status, newHeaders, r.bodyString


# =============================================================================

proc prodErrorPage(status:HttpCode): string =
  return html(head(title($status)),
            body(h1($status),
                "<hr/>",
                p(&"Nim Basolato {basolatoVersion}"),
                style = "text-align: center;"
            ),
            xmlns="http://www.w3.org/1999/xhtml")

proc devErrorPage(status:HttpCode, error: string): string =
  return html(
          head(title("Basolato Dev Error Page")),
          body(
            h1($status),
            h2("An error has occured in one of your routes."),
            p(b("Detail: ")),
            code(pre(error)),
            "<hr/>",
            p(&"Nim Basolato {basolatoVersion}", style = "text-align: center;"),
          ),
          xmlns="http://www.w3.org/1999/xhtml"
        )


template http404Route*() =
  echoErrorMsg(&"{$Http404}  {request.ip}  {request.path}")
  resp prodErrorPage(Http404)

template exceptionRoute*() =
  echoErrorMsg(&"{$Http500}  {request.ip}  {request.path}  {exception.msg}")
  when not defined(release):
    resp devErrorPage(Http500, exception.msg)
  else:
    resp prodErrorPage(Http500)

#[

template route*(r:Response, headers:openArray[tuple[key, value: string]]) =
  case r.responseType:
  of String:
    resp r.status, headers, r.bodyString
  of Json:
    var newHeaders = headers
    newHeaders.add(
      ("Content-Type", "application/json")
    )
    resp r.status, newHeaders, $(r.bodyJson)
  of Nil:
    echo getCurrentExceptionMsg()

]#
