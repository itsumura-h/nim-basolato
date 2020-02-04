import random, times, strutils
# framework
import base
# 3rd party
import nimAES

proc rundStr(n:openArray[int]):string =
  randomize()
  var n = n.sample()
  for _ in 1..n:
    add(result, char(rand(int('0')..int('z'))))


# ========== Csrf Token ====================
proc gen16Timestamp():string =
  getTime().toUnix().int().intToStr(16)

proc csrfEncript*():string =
  var aes = initAES()
  let salt = rundStr([16])
  let now = salt & gen16Timestamp()
  discard aes.setEncodeKey(SECRET_KEY)
  let iv = repeat(chr(1), 16).cstring
  let token = aes.encryptCBC(iv, now).toHex()
  return token

proc csrfDecript*(token:string):string =
  var token = token.parseHexStr()
  var aes = initAES()
  discard aes.setDecodeKey(SECRET_KEY)
  let iv = repeat(chr(1), 16).cstring
  let timestamp32 = aes.decryptCBC(iv, token)
  let timestamp16 = timestamp32[16..31]
  return timestamp16

# ========== Session ID ====================
# 5e36c9483fc935047d8faaf9 24 chars
proc sessionIdEncrypt*(sessionId:string):string =
  var sessionId = sessionId.align(32, '0')
  var aes = initAES()
  discard aes.setEncodeKey(SECRET_KEY)
  let iv = repeat(chr(1), 16).cstring
  let token = aes.encryptCBC(iv, sessionId).toHex()
  return token

proc sessionIdDecript*(token:string):string =
  var token = token.parseHexStr()
  var aes = initAES()
  discard aes.setDecodeKey(SECRET_KEY)
  let iv = repeat(chr(1), 16).cstring
  var sessionId = aes.decryptCBC(iv, token)
  sessionId = sessionId[8..31]
  return sessionId