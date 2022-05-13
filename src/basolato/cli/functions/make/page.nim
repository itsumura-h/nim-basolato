import os, strformat, terminal, strutils
import utils

proc makePage*(target:string, message:var string):int =
  let targetPath = &"{getCurrentDir()}/app/http/views/pages/{target}_view.nim"
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamelProcName(targetName)
  let relativeToApplicationPath = "../".repeat(target.split("/").len) & "layouts/application_view"

  var VIEW = &"""
import
  std/asyncdispatch,
  std/json,
  basolato/view,
  {relativeToApplicationPath}


proc impl():Future[string] [[.async.]] =
  style "css", style:'''
    <style>
      .className [[
      ]]
    </style>
  '''

  script ["idName"], script:'''
    <script>
    </script>
  '''

  tmpli html'''
    $(style)
    $(script)
    <div class="$(style.element("className"))">
    </div>
  '''

proc {targetCaptalized}View*():Future[string] [[.async.]] =
  let title = ''
  return applicationView(title, impl().await)
"""

  VIEW = VIEW.multiReplace(
    ("'", "\""),
    ("[[", "{"),
    ("]]", "}")
  )

  if isFileExists(targetPath): return 1
  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  f.write(VIEW)
  defer: f.close()

  message = &"Created page view {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
