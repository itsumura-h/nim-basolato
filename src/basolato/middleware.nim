import jester except redirect, setCookie
import base, security
# from private import render, redirect, errorRedirect
from controller import render, redirect, errorRedirect
import csrf_token

export jester.request
export base, security
export render, redirect, errorRedirect

proc checkCsrfToken*(request:Request) =
  if request.reqMethod == HttpPost or request.reqMethod == HttpPut or
        request.reqMethod == HttpPatch or request.reqMethod == HttpDelete:
    let token = request.params["csrf_token"]
    discard newCsrfToken(token).checkCsrfTimeout()
