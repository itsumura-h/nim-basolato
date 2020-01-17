import ../../src/basolato/middleware

proc hasLoginId*(request: Request):Response =
  try:
    let loginId = request.headers["X-login-id"]
    echo "loginId ==========" & loginId
  except:
    raise newException(Error403, "Can't get login id")

proc hasLoginToken*(request: Request):Response =
  try:
    let loginToken = request.headers["X-login-token"]
    echo "loginToken =======" & loginToken
  except:
    raise newException(Error403, "Can't get login token")
    
proc isLogin*(request: Request):Response =
  try:
    discard hasLoginId(request)
    discard hasLoginToken(request)
  except:
    return errorRedirect("/login")
