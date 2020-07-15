import ../../../../src/basolato/middleware
import ../../../../src/basolato/routing

template framework*() =
  checkCsrfToken(request).catch(Error403)
  checkAuthToken(request).catch(Error403)