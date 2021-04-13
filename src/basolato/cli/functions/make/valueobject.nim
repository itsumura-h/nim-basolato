import os, strformat, terminal, strutils


proc makeValueObject*(target, aggregate, message:var string):int =
  let targetPath = getCurrentDir() / "app/core/models" /  aggregate / &"{aggregate}_value_objects.nim"
  target = target.capitalizeAscii()
  let VALUEOBJECT = &"""


type {target}* = ref object
  value:string

proc new{target}*(value:string):{target} =
  result = new {target}
  result.value = value

proc `$`*(self:{target}):string =
  return self.value
"""

  createDir(parentDir(targetPath))

  var f = open(targetPath, fmAppend)
  defer: f.close()
  f.write(VALUEOBJECT)

  message = &"Added value object {target} in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
