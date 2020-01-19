import basolato/middleware
import basolato/routing
# from custom_headers_middleware import corsHeader

template framework*() =
  checkCsrfToken(request)

  # if request.reqMethod == HttpOptions:
  #   route(render(""), [corsHeader()])
