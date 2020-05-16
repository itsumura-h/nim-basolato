import ../../src/basolato/response
import ../../src/basolato/security

template always_create_cookie*() =
  var response = response(result)
  if request.cookies.hasKey("session_id"):
    route(response)
  else:
    let auth = newAuth()
    response = response.setAuth(auth)
    route(response)
