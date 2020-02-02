import random, times, strutils
# 3rd party
import nimAES

proc rundStr*(n:openArray[int]):string =
  randomize()
  var n = n.sample()
  for _ in 1..n:
    add(result, char(rand(int('0')..int('z'))))

let
  SECRET_KEY = rundStr([16, 24, 32])
  SALT = rundStr([16])

# ========== Csrf Token ====================
proc gen16Timestamp():string =
  getTime().toUnix().int().intToStr(16)

proc csrfEncript*():string =
  var aes = initAES()
  let now = SALT & gen16Timestamp()
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

# ========== Login Token ====================
# 5e36c9483fc935047d8faaf9 24 chars
proc loginEncrypt*(token:string):string =
  var token = token.align(32, '0')
  var aes = initAES()
  discard aes.setEncodeKey(SECRET_KEY)
  let iv = repeat(chr(1), 16).cstring
  var secretToken = aes.encryptCBC(iv, token).toHex()
  return secretToken

proc loginDecript*(token:string):string =
  echo token
  var token = token.parseHexStr()
  var aes = initAES()
  discard aes.setDecodeKey(SECRET_KEY)
  let iv = repeat(chr(1), 16).cstring
  let token32 = aes.decryptCBC(iv, token)
  echo token32
  token = token32[8..31]
  return token