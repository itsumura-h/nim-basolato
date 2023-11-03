import
  std/asyncdispatch,
  std/options,
  std/strformat
from ./session_db import globalNonce
import ./session


type CsrfToken* = ref object
  token:string

proc new*(_:type CsrfToken, token=""):CsrfToken =
  return CsrfToken(token:token)

func getToken*(self:CsrfToken):string =
  self.token

proc checkCsrfValid*(self:CsrfToken, session:Option[Session]):Future[bool] {.async.} =
  echo "=== checkCsrfValid"
  echo "self.token: ",self.token
  echo "session: ",session.repr
  echo "session.get(\"nonce\").await: ",session.get("nonce").await
  if not session.isSome:
    return false
  let nonce = session.get("nonce").await
  return self.token == nonce

proc csrfToken*():CsrfToken =
  ## used in view
  return CsrfToken.new(globalNonce)

proc toString*(self:CsrfToken):string =
  return &"""<input type="hidden" name="csrf_token" value="{self.token}">"""
