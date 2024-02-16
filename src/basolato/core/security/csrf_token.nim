import std/asyncdispatch
import std/options
import std/strformat
import ./session


type CsrfToken* = object
  token:string

proc new*(_:type CsrfToken, token=""):CsrfToken =
  return CsrfToken(token:token)

func getToken*(self:CsrfToken):string =
  self.token

proc checkCsrfValid*(self:CsrfToken, session:Option[Session]):Future[bool] {.async.} =
  if not session.isSome:
    return false
  let csrfToken = session.get("csrf_token").await
  return self.token == csrfToken

proc csrfToken*():CsrfToken =
  ## used in view
  return CsrfToken.new(globalCsrfToken)

proc toString*(self:CsrfToken):string =
  return &"""<input type="hidden" name="csrf_token" value="{self.token}">"""
