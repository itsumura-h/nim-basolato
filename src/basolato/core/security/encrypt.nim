import random, strutils
import nimAES
import ../baseEnv

randomize()

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
  let input = input.commonCtr().toHex()
  return input

proc decryptCtr*(input:string):string =
  if input.len == 0: return ""
  try:
    let input = input.parseHexStr().commonCtr()
    return input
  except:
    return ""
