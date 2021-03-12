import os, strformat, terminal


proc makeValueObject*(target, targetPath, message:var string):int =
  let targetPath = &"{getCurrentDir()}/app/core/models" / targetPath & ".nim"
  let VALUEOBJECT = &"""


type {target}* = ref object
  value:string

proc new{target}*(value:string):{target} =
  result = new {target}
  result.value = value

proc get*(this:{target}):string =
  return this.value
"""

  createDir(parentDir(targetPath))

  var f = open(targetPath, fmAppend)
  defer: f.close()
  f.write(VALUEOBJECT)

  message = &"Added value object {target} in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
