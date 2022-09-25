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

proc secureRandStr*(size=21):string {.gcsafe.} =
  var tmp:string
  let size = size div 2
  for row in urandomBytes(size):
    tmp.add(row)
  return tmp.toHex()

proc randStr*(
  size: int = 21,
  alphabet: string = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
):string {.gcsafe.} =
  for _ in 1..size:
    result.add(alphabet.sample())
