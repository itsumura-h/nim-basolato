import os, tables, times, re, strformat

let
  sleepTime = 2
  currentDir = getCurrentDir()
  cmds = [
    "killall main",
    "nim c main.nim",
    "./main &"
  ]
var
  files: Table[string, Time]

proc runCommand(cmds:openArray[string]) =
  for cmd in cmds:
    discard execShellCmd(cmd)

proc serve*() =
  runCommand(cmds)
  while true:
    sleep sleepTime * 1000
    for f in walkDirRec(currentDir, {pcFile}):
      if f.find(re"\.nim$") > -1:
        let modTime = getFileInfo(f).lastWriteTime
        if not files.hasKey(f):
          files[f] = modTime
          # debugEcho &"Skip {f} because of first checking"
          continue
        if files[f] == modTime:
          # debugEcho &"Skip {f} because of the file has not modified"
          continue
        # modified
        runCommand(cmds)
        files[f] = modTime
