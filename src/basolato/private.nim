import httpcore, json, macros, options, os, std/sha1, tables, times
# framework
import base
# 3rd party
import jester except redirect, setCookie, setHeader, resp
import bcrypt, flatdb, templates

export base
export jester except redirect, setCookie, setHeader, resp
export bcrypt, flatdb, templates


template middleware*(procs:varargs[Response]) =
  for p in procs:
    if p == nil:
      # echo getCurrentExceptionMsg()
      discard
    else:
      route(p)
      break


# # ==================== controller =============================================
# # String
# proc render*(body:string):Response =
#   return Response(status:Http200, bodyString:body, responseType:String)

# proc render*(status:HttpCode, body:string):Response =
#   return Response(status:status, bodyString:body, responseType:String)


# # Json
# proc render*(body:JsonNode):Response =
#   return Response(status:Http200, bodyJson:body, responseType:Json)

# proc render*(status:HttpCode, body:JsonNode):Response =
#   return Response(status:status, bodyJson:body, responseType:Json)


# proc redirect*(url:string) : Response =
#   return Response(
#     status:Http303, url:url, responseType: Redirect
#   )

# proc errorRedirect*(url:string): Response =
#   return Response(
#     status:Http302, url:url, responseType: Redirect
#   )

# ==================== view ===================================================

proc get*(val:JsonNode):string =
  case val.kind
  of JString:
    return val.getStr
  of JInt:
    return $(val.getInt)
  of JFloat:
    return $(val.getFloat)
  of JBool:
    return $(val.getBool)
  of JNull:
    return ""
  else:
    raise newException(JsonKindError, "val is array")
