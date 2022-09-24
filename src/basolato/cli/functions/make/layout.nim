import os, strformat, terminal, strutils
import utils

proc makeLayout*(target:string, scf=false, message:var string):int =
  let targetDir = &"{getCurrentDir()}/app/http/views/layouts/{target}"
  let targetName = target.split("/")[^1]
  let targetViewPath = &"{getCurrentDir()}/app/http/views/layouts/{target}/{targetName}_view.nim"
  let targetViewModelPath = &"{getCurrentDir()}/app/http/views/layouts/{target}/{targetName}_view_model.nim"
  # let targetScriptPath = &"{getCurrentDir()}/app/http/views/layouts/{target}/{targetName}_script.nim"
  let targetCaptalizedType = snakeToCamel(targetName)
  let targetCaptalizedProc = snakeToCamelProcName(targetName)

  var VIEW_MODEL = &"""
import std/asyncdispatch
import std/json


type {targetCaptalizedType}ViewModel* = ref object

proc new*(_:type {targetCaptalizedType}ViewModel):{targetCaptalizedType}ViewModel =
  discard
"""
  var VIEW = ""
  if scf:
    VIEW = &"""
#? stdtmpl(toString="toString") | standard
#import std/asyncdispatch
#import std/json
#import basolato/view
#import ./{targetName}_view_model
# proc {targetCaptalizedProc}View*():Future[Component] [[.async.]] =
# result = Component.new()
<div>
</div
"""
  else:
    VIEW = &"""
import std/asyncdispatch
import std/json
import basolato/view
import ./{targetName}_view_model


proc {targetCaptalizedProc}View*():Future[Component] [[.async.]] =
  let style = styleTmpl(Css, '''
    <style>
      .className [[
      ]]
    </style>
  '''

  tmpli html'''
    $(style)
    <div class="$(style.element("className"))">
    </div>
  '''
"""
#   var SCRIPT = """
# import std/[jsffi, jsfetch, jscore, asyncjs]

# proc add(a, b:int):int {.exportc.} =
#   return a + b
# """

  VIEW = VIEW.multiReplace(
    ("'", "\""),
    ("[[", "{"),
    ("]]", "}")
  )

  if isDirExists(targetDir): return 1
  createDir(targetDir)

  var f = open(targetViewPath, fmWrite)
  f.write(VIEW)
  f = open(targetViewModelPath, fmWrite)
  f.write(VIEW_MODEL)
  # f = open(targetScriptPath, fmWrite)
  # f.write(SCRIPT)
  defer: f.close()

  message = &"Created layout view in {targetViewPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  message = &"Created layout view model in {targetViewModelPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  # message = &"Created layout script in {targetScriptPath}"
  # styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
