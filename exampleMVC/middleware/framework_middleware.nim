import strutils
import ../../src/basolato/middleware
from custom_headers_middleware import corsHeader

template framework*() =
  if not request.path.contains("."):
    checkCsrfToken(request).catch()
    checkAuthTokenValid(request).catch()
    # checkCsrfToken(request, Error302, "/login")
    # checkCsrfToken(request, Error403, getCurrentExceptionMsg())
    if request.reqMethod == HttpOptions:
      route(render(""), [corsHeader()])

#[
checkCsrfToken(request)
  .catch(Error500, "error")

checkCsrfToken(request)
  .redirect("/login")

]#