import os, strformat, terminal, strutils
import utils

proc makePage*(target:string, message:var string):int =
  let targetPath = &"{getCurrentDir()}/app/http/views/pages/{target}_view.nim"
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamelProcName(targetName)
  let relativeToApplicationPath = "../".repeat(target.split("/").len) & "layouts/application_view"

  var VIEW = &"""
import basolato/view
import {relativeToApplicationPath}

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

proc impl():string = tmpli html'''
$(style)
$(script)
<div class="$(style.element("className"))">
</div>
'''

proc {targetCaptalized}View*():string =
  let title = ''
  return applicationView(title, impl())
"""

  VIEW = VIEW.replace("'", "\"").replace("[[", "{").replace("]]", "}")

  if isFileExists(targetPath): return 1
  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  f.write(VIEW)
  defer: f.close()

  message = &"Created page view {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
