import basolato/middleware

proc checkCsrfTokenMiddleware*(r:Request, p:Params) =
  checkCsrfToken(r, p).catch(Error403)

proc chrckAuthTokenMiddleware*(r:Request, p:Params) =
  checkAuthToken(r).catch(ErrorRedirect, "/")
