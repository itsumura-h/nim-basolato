import ../../../../src/basolato/middleware

proc checkCsrfTokenMiddleware*(r:Request, p:Params) =
  if not checkCsrfToken(r, p):
    raise newException(Error403, "Invalid csrf token")

proc checkAuthTokenMiddleware*(r:Request, p:Params) {.async.} =
  let auth = await newAuth(r)
  if not await auth.isLogin():
    # raise newException(ErrorAuthRedirect, "/signin")
    raise newException(ErrorRedirect, "/signin")
