import jester
import BaseClass

export jester

proc setContentType*(responseArg:Response):Response =
  var newHeaders = responseArg.headers
  case responseArg.responseType:
  of String:
    newHeaders.add(("Content-Type", "text/html;charset=utf-8"))
  of Json:
    newHeaders.add(("Content-Type", "application/json"))
  
  return Response(
    status: responseArg.status,
    bodyString: responseArg.bodyString,
    bodyJson: responseArg.bodyJson,
    responseType: responseArg.responseType,
    headers: newHeaders 
  )

template route*(r:Response) =
  let r2 = setContentType(r)
  case r2.responseType:
  of String:
    resp r2.status, r2.headers, r2.bodyString
  of Json:
    resp r2.status, r2.headers, $(r2.bodyJson)

# =============================================================================

proc joinHeader*(responseArg:Response,
                headers:openArray[tuple[key, value: string]]):Response =
  var newHeaders = responseArg.headers

  if newHeaders.len > 0:
    for h in headers:
      newHeaders.add(h)
  else:
    newHeaders = @headers

  case responseArg.responseType:
  of String:
    newHeaders.add(("Content-Type", "text/html;charset=utf-8"))
  of Json:
    newHeaders.add(("Content-Type", "application/json"))

  return Response(
    status: responseArg.status,
    bodyString: responseArg.bodyString,
    bodyJson: responseArg.bodyJson,
    responseType: responseArg.responseType,
    headers: newHeaders 
  )

template route*(responseArg:Response,
                middleareHeaders:openArray[tuple[key, value: string]]) =
  let r2 = joinHeader(responseArg, middleareHeaders)
  case r2.responseType:
  of String:
    resp r2.status, r2.headers, r2.bodyString
  of Json:
    resp r2.status, r2.headers, $(r2.bodyJson)



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