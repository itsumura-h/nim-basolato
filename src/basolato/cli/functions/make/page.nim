import os, strformat, terminal, strutils
import utils

proc makePage*(target:string, scf=false, message:var string):int =
  let targetPath = &"{getCurrentDir()}/app/http/views/pages/{target}_view.nim"
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamelProcName(targetName)
  let relativeToApplicationPath = "../".repeat(target.split("/").len) & "layouts/application_view"

  var VIEW = ""
  if scf:
    VIEW = &"""
#? stdtmpl(toString="toString") | standard
#import std/asyncdispatch
#import std/json
#import basolato/view
#import {relativeToApplicationPath}
#proc {targetCaptalized}View*():Future[Component] [[.async.]] =
# result = Component.new()
<div>
</div>
"""
  else:  
    VIEW = &"""
import std/asyncdispatch
import std/json
import basolato/view
import {relativeToApplicationPath}


proc impl():Future[Component] [[.async.]] =
  let style = styleTmpl(Css, '''
    <style>
      .className [[
      ]]
    </style>
  ''')

  tmpli html'''
    $(style)
    <div class="$(style.element("className"))">
    </div>
  '''

proc {targetCaptalized}View*():Future[Component] [[.async.]] =
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
