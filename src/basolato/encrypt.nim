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
proc encryptCfb*(input:string):string =
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

proc decryptCfb*(input:string):string =
  var
    input = input.parseHexStr()
    ctx: AESContext
    offset = 0
    iv = iv()
  discard ctx.setEncodeKey(SECRET_KEY)
  var output = ctx.decryptCFB128(offset, iv, input)
  output = output[16..high(output)]
  return output

# ========== CTR ====================
proc commonCtr(input:string):string =
  var ctx: AESContext
  zeroMem(addr(ctx), sizeof(ctx))
  discard ctx.setEncodeKey(SECRET_KEY)
  var offset = 0
  var counter: array[0..15, uint8]
  var nonce = cast[cstring](addr(counter[0]))
  zeroMem(addr(counter), sizeof(counter))
  return ctx.cryptCTR(offset, nonce, input)

proc encryptCtr*(input:string):string =
  var input = randStr([16]) & input
  input.commonCtr().toHex()

proc decryptCtr*(input:string):string =
  var input = input.parseHexStr()
  var output = input.commonCtr()
  return output[16..high(output)]