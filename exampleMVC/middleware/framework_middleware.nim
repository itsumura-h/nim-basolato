import ../../src/basolato/middleware
# from custom_headers_middleware import corsHeader

template framework*() =
  checkCsrfToken(request)
  # checkCsrfToken(request, Error302, "/login")
  # checkCsrfToken(request, Error403, getCurrentExceptionMsg())

  try:
    checkCookieToken(request)
  except Exception:
    echo getCurrentExceptionMsg()
    discard
  

  # if request.reqMethod == HttpOptions:
  #   route(render(""), [corsHeader()])
