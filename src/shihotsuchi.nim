import json
import jester

# =============================================================================
# Routing
# =============================================================================

type
  Response* = ref object
    status*:HttpCode
    bodyString*: string
    bodyJson*: JsonNode
    responseType*: ResponseType

  ResponseType* = enum
    Nil
    String
    Json


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


# =============================================================================
# Controller
# =============================================================================

type BaseController* = ref object of RootObj
    request:Request

proc getRequest*(this:BaseController):Request =
  return this.request


# String
proc render*(this:BaseController, body:string):Response =
  return Response(status:Http200, bodyString:body, responseType:String)

proc render*(this:BaseController, status:HttpCode, body:string):Response =
  return Response(status:status, bodyString:body, responseType:String)


# Json
proc render*(this:BaseController, body:JsonNode):Response =
  return Response(status:Http200, bodyJson:body, responseType:Json)

proc render*(this:BaseController, status:HttpCode, body:JsonNode):Response =
  return Response(status:status, bodyJson:body, responseType:Json)


# =============================================================================
# Middleware
# =============================================================================

template middleware*(procs:varargs[Response]) =
  for p in procs:
    if p == nil:
      echo getCurrentExceptionMsg()
    else:
      route(p)
      break
