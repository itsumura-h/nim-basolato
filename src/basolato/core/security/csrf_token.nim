import times, strformat
import ./token
import ../baseEnv

type CsrfToken* = ref object
  token:Token


proc newCsrfToken*(token=""):CsrfToken =
  return CsrfToken(token: newToken(token))

func getToken*(self:CsrfToken): string =
  self.token.getToken()

proc csrfToken*(token=""):string =
  var token = newCsrfToken(token).getToken()
  return &"""<input type="hidden" name="csrf_token" value="{token}">"""

proc checkCsrfTimeout*(self:CsrfToken):bool =
  var timestamp:int
  try:
    timestamp = self.token.toTimestamp()
  except:
    raise newException(Exception, "Invalid csrf token")

  if getTime().toUnix > timestamp + SESSION_TIME * 60:
    raise newException(Exception, "Timeout")
  return true
