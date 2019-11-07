import jester
import BaseClass

export jester


template route*(r:Response) =
  case r.responseType
  of String:
    if r.headers.len > 0:
      var r2 = r
      r2.headers.add(("Content-Type", "text/html;charset=utf-8"))
      resp r2.status, r2.headers, r2.bodyString
    else:
      echo "====== 普通 ======="
      resp r.status, r.bodyString
  of Json:
    if r.headers.len > 0:
      var r2 = r
      r2.headers.add(("Content-Type", "application/json"))
      resp r2.status, r2.headers, $(r2.bodyJson)
    else:
      let header = [("Content-Type", "application/json")]
      resp r.status, header, $(r.bodyJson)
  of Nil:
    echo getCurrentExceptionMsg()


# template route*(r:Response, headers:openArray[tuple[key, value: string]]) =
#   case r.responseType:
#   of String:
#     if r.headers.len > 0:
#       var r2 = r
#       r2.headers.add(("Content-Type", "text/html;charset=utf-8"))
#       for h in headers:
#         r2.headers.add(h)
#       resp r2.status, r2.headers, r2.bodyString
#     else:
#       resp r.status, headers, r.bodyString
#   of Json:
#     if r.headers.len > 0:
#       var r2 = r
#       for h in headers:
#         r2.headers.add(h)
#       h2.headers.add(("Content-Type", "application/json"))
#       resp r2.status, r2.headers, $(r.bodyJson)
#     else:
#       var newHeaders = headers
#       newHeaders.add(
#         ("Content-Type", "application/json")
#       )
#       resp r.status, newHeaders, $(r.bodyJson)
#   of Nil:
#     echo getCurrentExceptionMsg()



template route*(r:Response, headers:seq[tuple[key, value: string]]) =
  case r.responseType:
  of String:
    var newHeaders = headers
    newHeaders.add(("Content-Type", "text/html;charset=utf-8"))
    if r.headers.len > 0:
      for h in r.headers:
        newHeaders.add(h)
    resp r.status, newHeaders, r.bodyString
  of Json:
    var newHeaders = headers
    newHeaders.add(
      ("Content-Type", "application/json")
    )
    resp r.status, newHeaders, $(r.bodyJson)
  of Nil:
    echo getCurrentExceptionMsg()



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