import std/httpcore
import ./core/base; export base
import ./core/route; export route
import ./core/header; export header
import ./core/response; export response
import ./core/security/cookie; export cookie
import ./core/security/context; export context

when defined(httpbeast) or defined(httpx):
  import ./core/libservers/nostd/request; export request
else:
  import ./core/libservers/std/request; export request


type MiddlewareResult* = ref object
  hasError: bool
  message: string

proc new*(_:type MiddlewareResult, hasError:bool, message:string):MiddlewareResult =
  return MiddlewareResult(
    hasError:hasError,
    message:message,
  )

func hasError*(self:MiddlewareResult):bool =
  return self.hasError

func message*(self:MiddlewareResult):string =
  return self.message

func next*(status:HttpCode=HttpCode(200), body="", headers:HttpHeaders=newHttpHeaders()):Response =
  return Response.new(status, body, headers)
