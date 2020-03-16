import os, tables, times, re, strformat, osproc, streams

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
  isModified = false
  p: Process
  pid = 0

proc handler() {.noconv.} =
  discard execShellCmd(&"kill {pid}")
  echo "===== Stop running server ====="
  quit 0
setControlCHook(handler)

proc runCommand() =
  if pid != 0:
    discard execShellCmd(&"kill {pid}")
  discard execShellCmd("nim c main.nim")
  try:
    p = startProcess("./main", currentDir, ["&"])
    pid = p.processID()
    # present terminal
    var outp = outputStream(p)
    var line = newStringOfCap(120).TaintedString
    while true:
      if isModified:
        echo "===break"
        break
      if outp.readLine(line):
        echo line
      else:
        echo "===break"
        break
    close(p)
  except:
    echo getCurrentExceptionMsg()

proc serve*() =
  runCommand()
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
        isModified = true
        files[f] = modTime
      
    if isModified:
      isModified = false
      runCommand()
