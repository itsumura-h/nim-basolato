import random, strutils

randomize()

proc urandomBytes(count: int): seq[char]  =
  var f: File
  try:
    f = open("/dev/urandom")
    result = newSeq[char](count)
    discard f.readChars(result)
  except Exception:
    raise newException(Exception, "Error reading from urandom")
  finally:
    f.close()


proc secureCompare*(a, b: string): bool {.gcsafe.} =
  ## Constant-time string comparison to mitigate timing attacks.
  ## Returns true only if a == b (same length and contents).
  var diff = a.len xor b.len
  let maxLen = max(a.len, b.len)
  for i in 0..<maxLen:
    let c = if i < a.len: uint8(a[i]) else: 0u8
    let d = if i < b.len: uint8(b[i]) else: 0u8
    diff = diff or (c xor d).int
  return diff == 0

proc secureRandStr*(size=21):string {.gcsafe.} =
  ## Returns a hex string of length about `size` (when `size` is odd, length is `size - 1`).
  ## Uses size div 2 bytes from /dev/urandom, so output length is 2 * (size div 2).
  var tmp:string
  let n = size div 2
  for row in urandomBytes(n):
    tmp.add(row)
  return tmp.toHex()


proc randStr*(
  size: int = 21,
  alphabet: string = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
):string {.gcsafe.} =
  for _ in 1..size:
    result.add(alphabet.sample())
