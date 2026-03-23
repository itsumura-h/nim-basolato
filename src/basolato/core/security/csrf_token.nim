import std/asyncdispatch
import std/options
import std/strformat
import std/strutils
import ./session
import ./random_string


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
  return secureCompare(self.token, csrfToken)

func escapeHtmlAttr*(s: string): string =
  result = newStringOfCap(s.len)
  for c in s:
    case c
    of '"': result.add("&quot;")
    of '<': result.add("&lt;")
    of '>': result.add("&gt;")
    of '&': result.add("&amp;")
    else: result.add(c)

proc toString*(self:CsrfToken):string =
  let escaped = escapeHtmlAttr(self.token)
  return &"""<input type="hidden" name="csrf_token" value="{escaped}">"""
  # return &"""<input type="hidden" name="csrf_token" value="{self.token}">"""
