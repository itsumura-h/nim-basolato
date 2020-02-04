import random, strutils
# framework
import base
# 3rd party
import nimAES

proc randStr*(n:openArray[int]):string =
  randomize()
  var n = n.sample()
  for _ in 1..n:
    add(result, char(rand(int('0')..int('z'))))

proc iv():cstring =
  repeat(chr(1), 16).cstring

# ========== CFB ====================
proc encrypt*(input:string):string =
  var
    ctx: AESContext
    offset = 0
    iv = iv()
  zeroMem(addr(ctx), sizeof(ctx))
  let salt = randStr([16])
  var input = salt & input
  discard ctx.setEncodeKey(SECRET_KEY)
  let token = ctx.encryptCFB128(offset, iv, input).toHex()
  return token

proc decrypt*(input:string):string =
  var
    input = input.parseHexStr()
    ctx: AESContext
    offset = 0
    iv = iv()
  discard ctx.setEncodeKey(SECRET_KEY)
  var output = ctx.decryptCFB128(offset, iv, input)
  output = output[16..high(output)]
  return output
