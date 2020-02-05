# framework
import base, security
from controller import render, redirect, errorRedirect
# 3rd party
import jester except redirect, setCookie

# framework
export base, security, render, redirect, errorRedirect
# 3rd party
export jester.request


proc checkCsrfToken*(request:Request) =
  if request.reqMethod == HttpPost or request.reqMethod == HttpPut or
        request.reqMethod == HttpPatch or request.reqMethod == HttpDelete:
    let token = request.params["csrf_token"]
    discard newCsrfToken(token).checkCsrfTimeout()
