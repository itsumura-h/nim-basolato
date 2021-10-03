import os, strformat, terminal, strutils


proc makeValueObject*(aggregate, target, message:var string):int =
  let targetName = aggregate.split("/")[^1]
  let targetPath = getCurrentDir() / "app/models" /  aggregate / &"{targetName}_value_objects.nim"
  target = target.capitalizeAscii()
  let VALUEOBJECT = &"""


type {target}* = ref object
  value:string

proc new*(_:type {target}, value:string):{target} =
  {target}(
    value: value
  )

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
