import json
# framework
import base, security, response, header, view
# 3rd party
import core/core

# framework
export core
export base, security, response, header


type Controller* = ref object of RootObj
  request*:Request
  auth*:Auth
  view*:View

proc newController*(this:typedesc, request:Request): this.type =
  if request.cookies.hasKey("session_id"):
    let auth = newAuth(request)
    return this.type(
      request:request,
      auth: auth,
      view: newView(auth)
    )
  else:
    return this.type(
      request:request,
      view:newView()
    )

# String
proc render*(body:string):Response =
  return Response(status:Http200, bodyString:body, responseType:String)

proc render*(status:HttpCode, body:string):Response =
  return Response(status:status, bodyString:body, responseType:String)


# Json
proc render*(body:JsonNode):Response =
  return Response(status:Http200, bodyJson:body, responseType:Json)

proc render*(status:HttpCode, body:JsonNode):Response =
  return Response(status:status, bodyJson:body, responseType:Json)


proc redirect*(url:string):Response =
  return Response(
    status:Http303, url:url, responseType: Redirect
  )

proc errorRedirect*(url:string):Response =
  return Response(
    status:Http302, url:url, responseType: Redirect
  )
