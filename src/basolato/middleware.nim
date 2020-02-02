import jester except redirect, setCookie
import base, auth
from private import render, redirect, errorRedirect
import csrf_token

export jester.request
export base, auth
export render, redirect, errorRedirect

proc checkCsrfToken*(request:Request) =
  if request.reqMethod == HttpPost:
    let token = request.params["csrfmiddlewaretoken"]
    discard newCsrfToken(token).checkCsrfTimeout()
