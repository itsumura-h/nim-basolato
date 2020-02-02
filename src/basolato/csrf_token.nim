import os, times, strutils, strformat
# framework
import logger, encript

type
  Token* = ref object
    token:string

  CsrfToken* = ref object
    token:Token

const
  SESSION_TIME = getEnv("SESSION_TIME").parseInt


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
  return &"""<input type="hidden" name="csrfmiddlewaretoken" value="{token}">"""

proc checkCsrfTimeout*(this:CsrfToken):bool =
  let timestamp = this.token.toTimestamp()
  if getTime().toUnix > timestamp + SESSION_TIME:
    raise newException(Exception, "Timeout")
  return true
