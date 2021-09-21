import os, strformat, terminal, strutils
import utils

proc makeLayout*(target:string, message:var string):int =
  let targetPath = &"{getCurrentDir()}/app/http/views/layouts/{target}_view.nim"
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamelProcName(targetName)

  var VIEW = &"""
import basolato/view

style "css", style:'''
<style>
  .className [[
  ]]
</style>
'''

script script:'''
<script>
</script>
'''

proc {targetCaptalized}View*():string = tmpli html'''
$(style)
$(script)
<div class="$(style.element("className"))">
</div>
'''
"""

  VIEW = VIEW.replace("'", "\"").replace("[[", "{").replace("]]", "}")

  if isFileExists(targetPath): return 1
  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  f.write(VIEW)
  defer: f.close()

  message = &"Created layout view in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
