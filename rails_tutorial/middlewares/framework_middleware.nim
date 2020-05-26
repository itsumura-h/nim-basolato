import re
import ../../src/basolato/middleware
import ../../src/basolato/routing
from custom_headers_middleware import corsHeader

template framework*() =
  echo "=== framework middleware"
  checkCsrfToken(request).catch()
  if request.path().match(re"\/users.*"):
    checkAuthToken(request).catch(Error301, "/")
  if request.reqMethod == HttpOptions:
    route(render(""), [corsHeader()])
