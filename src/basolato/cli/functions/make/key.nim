import std/os
import std/strformat
import std/strutils
import ./utils


proc makeKey*():int =
  let path = getCurrentDir() / ".env"
  var f = open(path, fmRead)
  defer: f.close()

  var newStr = newSeq[string]()
  for row in f.readAll().splitLines():
    if row.contains("SECRET_KEY"):
      let key = randStr(100)
      echo "key: ",key
      newStr.add(&"SECRET_KEY=\"{key}\"")
    else:
      newStr.add(row)

  f = open(path, fmWrite)
  f.write(newStr.join("\n"))
