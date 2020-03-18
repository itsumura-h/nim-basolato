import
  os, tables, times, re, strformat, osproc

let
  sleepTime = 1
  currentDir = getCurrentDir()

var
  files: Table[string, Time]
  isModified = false
  p: Process
  pid = 0

proc ctrlC() {.noconv.} =
  kill(p)
  discard execShellCmd(&"kill {pid}")
  echo "===== Stop running server ====="
  quit 0
setControlCHook(ctrlC)

proc runCommand() =
  if pid > 0:
    discard execShellCmd(&"kill {pid}")
  discard execShellCmd("nim c main")
  try:
    p = startProcess("./main", currentDir, ["&"],
                    options={poStdErrToStdOut,poParentStreams})
    pid = p.processID()
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
