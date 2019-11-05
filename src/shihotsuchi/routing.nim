import baseClass

template route*(r:Response) =
  case r.responseType
  of String:
    resp r.status, r.bodyString
  of Json:
    let header = [("Content-Type", "application/json")]
    resp r.status, header, $(r.bodyJson)


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
