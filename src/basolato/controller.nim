import json
# framework
import base, security, response
from private import render, redirect, errorRedirect#, header
# 3rd party
import jester except redirect, setCookie, setHeader, resp

# framework
export base, security, response
export render, redirect, errorRedirect, header
# 3rd party
export jester except redirect, setCookie, setHeader, resp

type Controller* = ref object of RootObj
  request*:Request
  auth*:Auth

proc newController*(this:typedesc, request:Request): this.type =
  var auth = Auth(isLogin:false)
  if request.cookies.hasKey("session_id"):
    auth = request.newAuth()
  return this.type(
    request:request,
    auth: auth
  )
