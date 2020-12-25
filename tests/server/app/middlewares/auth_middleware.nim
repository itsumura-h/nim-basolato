import ../../../../src/basolato/middleware

proc checkCsrfTokenMiddleware*(r:Request, p:Params) =
  checkCsrfToken(r, p).catch(Error403)

proc checkAuthTokenMiddleware*(r:Request, p:Params) =
  checkAuthToken(r).catch(Error403)
