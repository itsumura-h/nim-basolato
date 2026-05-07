import asyncdispatch
import ../../../../../src/basolato/middleware


const jwtAlg = "HS256"

proc checkCsrfToken*(c:Context):Future[Response] {.async.} =
  try:
    checkCsrfTokenForMpaHelper(c, jwtAlg).await
    return next()
  except:
    # Define your own error handling logic here
    # return errorRedirect("/signin")
    return render(Http403, getCurrentExceptionMsg())

proc sessionFromCookie*(c:Context):Future[Response] {.async.} =
  try:
    let cookies = sessionFromCookieHelper(c, jwtAlg).await
    return next().setCookie(cookies)
  except:
    # Define your own error handling logic here
    let cookies = createNewSessionHelper(c, jwtAlg).await
    return next().setCookie(cookies)
    # return errorRedirect("/signin").setCookie(cookies)
