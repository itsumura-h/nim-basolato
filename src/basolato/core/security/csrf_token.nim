import strformat
from ./session_db import globalNonce


type CsrfToken* = ref object
  token:string

proc new*(_:type CsrfToken, token=""):CsrfToken =
  return CsrfToken(token:token)

func getToken*(self:CsrfToken):string =
  self.token

proc checkCsrfValid*(self:CsrfToken):bool =
  return self.token == globalNonce

proc csrfToken*():CsrfToken =
  ## used in view
  return CsrfToken.new(globalNonce)

proc toString*(self:CsrfToken):string =
  return &"""<input type="hidden" name="csrf_token" value="{self.token}">"""
