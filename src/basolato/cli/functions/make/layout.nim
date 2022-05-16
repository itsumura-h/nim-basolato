import os, strformat, terminal, strutils
import utils

proc makeLayout*(target:string, message:var string):int =
  let targetDir = &"{getCurrentDir()}/app/http/views/layouts/{target}"
  let targetName = target.split("/")[^1]
  let targetViewPath = &"{getCurrentDir()}/app/http/views/layouts/{target}/{targetName}_view.nim"
  let targetViewModelPath = &"{getCurrentDir()}/app/http/views/layouts/{target}/{targetName}_view_model.nim"
  let targetCaptalizedType = snakeToCamel(targetName)
  let targetCaptalizedProc = snakeToCamelProcName(targetName)

  var VIEW_MODEL = &"""
import
  std/asyncdispatch,
  std/json

type {targetCaptalizedType}ViewModel* = ref object

proc new*(_:type {targetCaptalizedType}ViewModel):{targetCaptalizedType}ViewModel =
  discard
"""

  var VIEW = &"""
import
  std/asyncdispatch,
  std/json,
  basolato/view,
  ./{targetName}_view_model


proc {targetCaptalizedProc}View*():Future[string] [[.async.]] =
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
    $<style>
    $<script>
    <div class="$(style.element("className"))">
    </div>
  '''
"""

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
  defer: f.close()

  message = &"Created layout view in {targetViewPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  message = &"Created layout view model in {targetViewModelPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
