import jester
import BaseClass

export jester

template route*(r:Response) =
  case r.responseType
  of String:
    resp r.status, r.bodyString
  of Json:
    if r.status == Http200:
      resp r.bodyJson
    else:
      let header = [("Content-Type", "application/json")]
      resp r.status, header, $(r.bodyJson)
  of Nil:
    echo getCurrentExceptionMsg()


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
