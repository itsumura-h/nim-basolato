import strutils
import ../../src/basolato/middleware
from custom_headers_middleware import corsHeader

template framework*() =
  if not request.path.contains("."):
    checkCsrfToken(request).catch()
    checkAuthToken(request).catch(ErrorAuthRedirect, "/posts")

template cors*() =
  if request.reqMethod == HTTPOptions:
    route(render(""), [corsHeader()])
