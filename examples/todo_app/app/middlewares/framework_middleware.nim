import ../../../../src/basolato/middleware
import ../../../../src/basolato/routing
from custom_headers_middleware import corsHeader

template framework*() =
  checkCsrfToken(request).catch()
  checkAuthToken(request).catch(Error301, "/login")
  if request.reqMethod == HttpOptions:
    route(render(""), [corsHeader()])
