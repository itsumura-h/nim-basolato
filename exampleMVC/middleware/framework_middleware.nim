import ../../src/basolato/middleware
# from custom_headers_middleware import corsHeader

template framework*() =
  try:
    checkCsrfToken(request)
  except Exception:
    # raise newException(Error403, getCurrentExceptionMsg())
    echo getCurrentExceptionMsg()
    raise newException(Error302, "/login")

  try:
    checkCookieToken(request)
  except Exception:
    echo getCurrentExceptionMsg()
    discard
  

  # if request.reqMethod == HttpOptions:
  #   route(render(""), [corsHeader()])
