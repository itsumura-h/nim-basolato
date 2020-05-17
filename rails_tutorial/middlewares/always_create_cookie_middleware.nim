import ../../src/basolato/response
import ../../src/basolato/security

template always_create_cookie*() =
  var response = response(result)
  if not request.cookies.hasKey("session_id"):
    let auth = newAuth()
    response = response.setAuth(auth)
  route(response)
