import math, lenientops

proc urandombytes(count: int): seq[char]  =
  var f: File
  try:
    f = open("/dev/urandom")
    result = newSeq[char](count)
    discard f.readChars(result)
  except Exception:
    raise newException(Exception, "Error reading from urandom")
  finally:
    f.close()

proc urandom(count: int): seq[byte]  =
  let bytes = urandombytes(count)
  result = newSeq[byte](count)
  for i in 0..count - 1:
    result[i] = cast[byte](bytes[i])

proc genRandomBytes(step: int): seq[byte] =
    result = urandom(step)

proc randStr*(
  size: int = 21,
  alphabet: string = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
): string {.gcsafe.} =
  if alphabet == "":
    result = ""
  if size < 1:
    result = ""

  let masks = [15, 31, 63, 127, 255]
  var mask: int = 1

  for m in masks:
    if m >= len(alphabet) - 1:
      mask = m
      break

  var step = int(ceil(1.6 * mask * size / len(alphabet)))
  var nanoID: string

  while true:
    var randomBytes: seq[byte]
    randomBytes = genRandomBytes(step)
    for i in 0..step-1:
      var randByte = randomBytes[i].int and mask
      if randByte < len(alphabet):
        if alphabet[randByte] in alphabet:
          nanoID.add(alphabet[randByte])
          if len(nanoID) >= size:
            return nanoID
