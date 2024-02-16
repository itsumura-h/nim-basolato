import std/asyncdispatch
import std/options
import std/times
import std/tables
import std/json
import ../core/baseEnv
import ../core/security/context
import ../core/security/session
import ../core/security/cookie
import ../core/security/csrf_token
import ../middleware


proc checkCsrfToken*(c:Context, p:Params):Future[Response] {.async.} =
  result = next()
  if [HttpPost, HttpPut, HttpPatch, HttpDelete].contains(c.request.httpMethod) and
  not (c.request.headers.hasKey("content-type") and c.request.headers["content-type"].contains("application/json")):
    echo "=== checkCsrfToken ==="
    echo p.getAll()
    try:
      if not p.hasKey("csrf_token"):
        raise newException(Exception, "csrf token is missing")
      let token = p.getStr("csrf_token")
      let csrfToken = CsrfToken.new(token)
      let sessionId = Cookies.new(c.request).get("session_id")
      let session = Session.new(sessionId).await
      if not csrfToken.checkCsrfValid(session).await:
        raise newException(Exception, "Invalid csrf token")
      return next()
    except:
      return render(Http403, getCurrentExceptionMsg())
