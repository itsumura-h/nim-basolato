import os, strutils, strformat
import ./utils

proc makeKey*():int =
  let path = getCurrentDir() / ".env"
  var f = open(path, fmRead)
  defer: f.close()

  var newStr = newSeq[string]()
  for row in f.readAll().splitLines():
    if row.contains("SECRET_KEY"):
      newStr.add(&"SECRET_KEY=\"{randStr(100)}\"")
    else:
      newStr.add(row)

  f = open(path, fmWrite)
  f.write(newStr.join("\n"))
