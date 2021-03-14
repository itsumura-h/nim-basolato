import os, strformat, terminal, strutils


proc makeValueObject*(target, targetPath, message:var string):int =
  targetPath = getCurrentDir() / "app/core/models" /  targetPath / "value_objects.nim"
  target = target.capitalizeAscii()
  let VALUEOBJECT = &"""


type {target}* = ref object
  value:string

proc new{target}*(value:string):{target} =
  result = new {target}
  result.value = value

proc get*(self:{target}):string =
  return self.value
"""

  createDir(parentDir(targetPath))

  var f = open(targetPath, fmAppend)
  defer: f.close()
  f.write(VALUEOBJECT)

  message = &"Added value object {target} in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
