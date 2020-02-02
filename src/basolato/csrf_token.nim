import os, times, strutils, strformat, random
# framework
import logger
# 3rd party
import nimAES

type
  Token* = ref object
    token:string

  CsrfToken* = ref object
    token:Token

const
  SESSION_TIME = getEnv("SESSION_TIME").parseInt

proc rundStr*(n:openArray[int]):string =
  randomize()
  var n = n.sample()
  for _ in 1..n:
    add(result, char(rand(int('0')..int('z'))))

let
  SECRET_KEY = rundStr([16, 24, 32])
  SALT = rundStr([16])

# ========== Token ====================
proc gen16Timestamp():string =
  getTime().toUnix().int().intToStr(16)

proc newToken*(token:string):Token =
  if token.len > 0:
    return Token(token:token)
  var aes = initAES()
  let now = SALT & gen16Timestamp()
  discard aes.setEncodeKey(SECRET_KEY)
  let iv = repeat(chr(1), 16).cstring
  let token = aes.encryptCBC(iv, now).toHex()
  return Token(token:token)

proc getToken*(this:Token):string =
  return this.token

proc toTimestamp*(this:Token): int =
  var token = this.getToken().parseHexStr()
  var aes = initAES()
  discard aes.setDecodeKey(SECRET_KEY)
  let iv = repeat(chr(1), 16).cstring
  let timestamp32 = aes.decryptCBC(iv, token)
  let timestamp16 = timestamp32[16..31]
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
