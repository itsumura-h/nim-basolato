import ../../../../src/basolato/middleware
import ../../../../src/basolato/routing
import ../../../../src/basolato/security
from custom_headers_middleware import corsHeader

template before_framework*() =
  if request.path.match(re"^(?!.*\.).*$"):
    checkCsrfToken(request).catch()
    if request.reqMethod == HttpOptions:
      route(render(""), [corsHeader()])
