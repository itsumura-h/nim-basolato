import os, times, strutils, strformat
# framework
import base, logger, encript

type
  Token* = ref object
    token:string

  CsrfToken* = ref object
    token:Token


# ========== Token ====================
proc newToken*(token:string):Token =
  if token.len > 0:
    return Token(token:token)
  let token = csrfEncript()
  return Token(token:token)

proc getToken*(this:Token):string =
  return this.token

proc toTimestamp*(this:Token): int =
  let timestamp16 = this.getToken().csrfDecript()
  return timestamp16.parseInt

# ========== CsrfToken ====================
proc newCsrfToken*(token:string):CsrfToken =
  return CsrfToken(token: newToken(token))

proc getToken*(this:CsrfToken): string =
  this.token.getToken()

proc csrfToken*(token=""):string =
  var token = newCsrfToken(token).getToken()
  return &"""<input type="hidden" name="csrf_token" value="{token}">"""

proc checkCsrfTimeout*(this:CsrfToken):bool =
  let timestamp = this.token.toTimestamp()
  if getTime().toUnix > timestamp + CSRF_TIME * 60:
    raise newException(Exception, "Timeout")
  return true
