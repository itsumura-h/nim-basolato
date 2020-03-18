import
  os, tables, times, re, strformat,# streams, osproc,
  asyncdispatch, asynctools, asyncstreams

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
  # p: Process
  p: AsyncProcess
  pid = 0
  # outp: Stream

proc ctrlC() {.noconv.} =
  kill(p)
  discard execShellCmd(&"kill {pid}")
  echo "===== Stop running server ====="
  quit 0
setControlCHook(ctrlC)

# https://github.com/cheatfate/asynctools/blob/b365f94ad134b1cbc031a64e4ecd3bebacd4ed15/asynctools/asyncproc.nim#L882
# proc display() {.async.} =
#   echo "=== display"
#   let bufferSize = 1024
#   var data = newStringOfCap(bufferSize)
#   while true:
#     sleep 2000
#     echo "=== while"
#     let res = await p.outputHandle.readInto(addr data[0], bufferSize)
#     if res > 0:
#       data.setLen(res)
#       echo data
#       data.setLen(bufferSize)
#     else:
#       echo "=== break"
#       break
#     sleep 2000
proc display() {.async.} =
  echo "=== display"
  let bufferSize = 1024
  var data = newStringOfCap(bufferSize)
  while true:
    sleep 2000
    echo "=== while"
    let res = await p.outputHandle.readInto(addr data[0], bufferSize)
    if res > 0:
      data.setLen(res)
      echo data
      data.setLen(bufferSize)
    else:
      echo "=== break"
      break
    sleep 2000
proc funcWithTimeout(time:int, cb:proc):string =
  var resultStr = ""

  proc checkTime(time:int):Future[int] =
    sleep time
    return 0

  proc process(cd:proc):Future[string] =
    return cd

  try:
    var resultCheckTime = await checkTime(time)
    var resultStr = await process(cd)
    if resultCheckTime == 0 and resultStr.len > 0:
      return resultStr
  except:
    discard

proc runCommand() =
  if pid > 0:
    discard execShellCmd(&"kill {pid}")
  discard execShellCmd("nim c main")
  try:
    p = startProcess("./main", currentDir, ["&"],
                    options={poInteractive})
    pid = p.processID()
  except:
    echo getCurrentExceptionMsg()
  discard display()

proc serve*() =
  runCommand()
  while true:
    sleep sleepTime * 1000
    for f in walkDirRec(currentDir, {pcFile}):
      if f.find(re"\.nim$") > -1:
        let modTime = getFileInfo(f).lastWriteTime
        discard display()
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

#[
  var p = startProcess(command, options = options + {poEvalCommand})
  var outp = outputStream(p)
  close inputStream(p)
  result = (TaintedString"", -1)
    var line = newStringOfCap(120).TaintedString
    while true:
      if outp.readLine(line):
        result[0].string.add(line.string)
        result[0].string.add("\n")
      else:
        result[1] = peekExitCode(p)
        if result[1] != -1: break
    close(p)

  proc display() =
    var outp = outputStream(p)
    close inputStream(p)
    var line = newStringOfCap(120).TaintedString
    while true:
      if outp.readLine(line):
        echo line
      else:
        break

  proc runCommand() =
    if pid > 0:
      discard execShellCmd(&"kill {pid}")
    discard execShellCmd("nim c main")
    try:
      p = startProcess("./main", currentDir, ["&"],
                      options={poInteractive})
      pid = p.processID()
    except:
      echo getCurrentExceptionMsg()
    display()
]#