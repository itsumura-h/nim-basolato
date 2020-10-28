import ../../../../src/basolato_httpbeast/middleware

proc checkCsrfTokenMiddleware*(r:Request, p:Params) =
  checkCsrfToken(r, p).catch(Error403)

proc chrckAuthTokenMiddleware*(r:Request, p:Params) =
  # checkAuthToken(r).catch(ErrorRedirect, "/")
  checkAuthToken(r).catch(Error403, "invalid session id")
