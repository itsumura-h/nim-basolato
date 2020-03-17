import os, tables, times, re, strformat, osproc, streams, terminal

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

proc ctrlC() {.noconv.} =
  close(p)
  discard execShellCmd(&"kill {pid}")
  echo "===== Stop running server ====="
  quit 0
setControlCHook(ctrlC)

proc display() =
  var outp = outputStream(p)
  outp = StringStream(outp)
  close inputStream(p)
  var line = newStringOfCap(120).TaintedString
  while true:
    echo outp.readAll().repr
    discard outp.readLine(line)
    echo line
    

proc runCommand() =
  if pid > 0:
    discard execShellCmd(&"kill {pid}")
  discard execShellCmd("nim c main")
  try:
    p = startProcess("./main", currentDir, ["&"])
    pid = p.processID()
    echo "=== modified display"
    display()
  except:
    echo getCurrentExceptionMsg()

proc serve*() =
  runCommand()
  while true:
    sleep sleepTime * 1000
    for f in walkDirRec(currentDir, {pcFile}):
      if f.find(re"\.nim$") > -1:
        let modTime = getFileInfo(f).lastWriteTime
        display()
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
