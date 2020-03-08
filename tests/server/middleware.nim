import ../../src/basolato/middleware

template framework*() =
  checkCsrfToken(request).catch(Error403)
  checkAuthToken(request).catch(Error403)
