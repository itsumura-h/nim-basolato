import
  os, tables, times, re, strformat, osproc, streams, options, asyncdispatch,
  asyncstreams

let
  sleepTime = 1
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
  # outp: Stream

proc ctrlC() {.noconv.} =
  close(p)
  discard execShellCmd(&"kill {pid}")
  echo "===== Stop running server ====="
  quit 0
setControlCHook(ctrlC)

# proc display() {.async.} =
#   echo "=== display"
#   var line = newStringOfCap(120).TaintedString
#   var outp = newFutureStream[string]("outputStream")
#   while not outp.finished():
#     echo "=== while"
#     var (hasValue, value) = await outp.read()
#     for line in value.lines():
#       echo line
#     break

    

proc runCommand() {.async.} =
  if pid > 0:
    discard execShellCmd(&"kill {pid}")
  discard execShellCmd("nim c main")
  try:
    p = startProcess("./main", currentDir, ["&"],
                    options={poInteractive})
    pid = p.processID()
    # outp = outputStream(p)
    discard outputStream(p)
    var outp = newFutureStream[string]("outputStream")
    outp.callback=(proc(future:FutureStream[string])=
      var (_, value) = future.read()
      echo value
    )
  except:
    echo getCurrentExceptionMsg()

proc serve*() =
  discard runCommand()
  while true:
    sleep sleepTime * 1000
    for f in walkDirRec(currentDir, {pcFile}):
      if f.find(re"\.nim$") > -1:
        let modTime = getFileInfo(f).lastWriteTime
        # discard display()
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
      discard runCommand()
