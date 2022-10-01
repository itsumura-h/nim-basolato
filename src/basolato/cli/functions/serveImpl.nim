import
  std/os,
  std/osproc,
  std/re,
  std/strutils,
  std/strformat,
  std/tables,
  std/terminal,
  std/times


let
  sleepTime = 2
  currentDir = getCurrentDir()

var
  files: Table[string, Time]
  isModified = false
  p: Process
  pid = 0

proc echoMsg(bg: BackgroundColor, msg: string) =
  styledEcho(fgBlack, bg, &"{msg} ", resetStyle)

proc ctrlC() {.noconv.} =
  if pid > 0:
    discard execShellCmd(&"kill {pid}")
  echoMsg(bgGreen, "[SUCCESS] Stoped dev server")
  quit 0
setControlCHook(ctrlC)

proc jsBuild() =
  for f in walkDirRec(currentDir, {pcFile}):
    if f.contains("_script.nim"):
      let jsFilePath = f.split(".")[0..^2].join(".")
      let cmd = &"nim js -d:nimExperimentalAsyncjsThen -d:release -o:{jsFilePath}.js {f}"
      echo cmd
      if execShellCmd(cmd) > 0:
        echoMsg(bgRed, "[FAILED] Build error")

proc runCommand(port:int, f:bool, httpbeast:bool, httpx:bool) =
  try:
    if pid > 0:
      discard execShellCmd(&"kill {pid}")
    let fStr = if f: "-f" else: ""
    let serverStr = if httpbeast: "-d:httpbeast" elif httpx: "-d:httpx" else: ""
    let cmd = &"""
      nim c \
      {fStr} \
      {serverStr} \
      --threads:off \
      -d:ssl \
      --putenv:PORT={port}\
      --spellSuggest:5 \
      main
    """
    echo cmd
    if execShellCmd(cmd) > 0:
      raise newException(Exception, "")
    echoMsg(bgGreen, "[SUCCESS] Building dev server")
    p = startProcess("./main", currentDir, ["&"],
                    options={poStdErrToStdOut,poParentStreams})
    pid = p.processID()
  except:
    echoMsg(bgRed, "[FAILED] Build error")
    echo getCurrentExceptionMsg()
    # quit 1

proc serve*(port=5000, force=false, httpbeast=false, httpx=false) =
  ## Run dev application with hot reload.
  jsBuild()
  runCommand(port, force, httpbeast, httpx)
  while true:
    sleep sleepTime * 1000
    for f in walkDirRec(currentDir, {pcFile}):
      if f.find(re"(\.nim|\.nims|\.html)$") > -1:
        var modTime: Time
        try:
          modTime = getFileInfo(f).lastWriteTime
        except:
          # file is deleted
          files.del(f)
          isModified = true
          break

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
        break

    if isModified:
      isModified = false
      # jsBuild()
      runCommand(port, false, httpbeast, httpx)
