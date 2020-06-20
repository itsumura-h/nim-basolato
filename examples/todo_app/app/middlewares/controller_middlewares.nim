import httpcore
import ../../../../src/basolato/middleware

proc hasSessionId*(request:Request) =
  if not request.headers().hasKey("session_id"):
    raise newException(Error302, "/login")
