import httpcore
import ../../../../src/basolato/middleware

proc hasSessionId*(request:Request) =
  if not newAuth(request).isLogin():
    raise newException(ErrorAuthRedirect, "/login")
