import std/os
import std/osproc
import std/strformat
import std/strutils
from std/tables import toTable


proc jsBuild() =
  for f in walkDirRec(getCurrentDir(), {pcFile}):
    if f.contains("_script.nim"):
      let jsFilePath = f.split(".")[0..^2].join(".")
      let cmd = &"nim js -d:nimExperimentalAsyncjsThen -d:release -o:{jsFilePath}.js {f}"
      echo cmd
      if execCmd(cmd) > 0:
        echo("[FAILED] Build error")
        quit(QuitFailure)


const BUILD_HELP* = {
  "optimize": "memory|speed"
}.toTable()

proc build*(workers:uint=0, force=false, httpbeast=false, httpx=false, autoRestart=false, optimize="memory", args:seq[string]) =
  ## Build for production.
  jsBuild()
  var outputFileName = "main"
  let fStr = if force: "-f" else: ""
  let serverStr = if httpbeast: "-d:httpbeast" elif httpx: "-d:httpx" else: ""
  let workers = if workers == 0: countProcessors().uint else: workers
  let optimize =
    if optimize == "speed":
      "--mm:markAndSweep -d:useRealtimeGC"
    else:
      "--mm:orc -d:useMalloc"

  try:
    outputFileName = args[0]
  except:
    discard

  var cmd = &"""
    nim c \
    {fStr} \
    {serverStr} \
    {optimize} \
    --threads:off \
    -d:ssl \
    -d:danger \
    -d:release \
    --parallelBuild:0 \
    --passC:"-flto"\
    --passL:"-flto" \
    --panics:on \
    --stackTrace \
    --lineTrace \
    --out:{outputFileName} \
    main.nim
  """
  echo cmd
  discard execCmd(cmd)

  var mainContent = ""
  if autoRestart:
    mainContent = "while [ 1 ]; do\n"
    for i in 1..workers:
      mainContent.add(&"  ./{outputFileName}")
      if i < workers:
        mainContent.add(" & \\\n")
      else:
        mainContent.add("\n")
    mainContent.add("done")
  else:
    for i in 1..workers:
      mainContent.add(&"./{outputFileName}")
      if i < workers:
        mainContent.add(" & ")
  
  let processes = if workers > 1: "processes" else: "process"

  let startServer = &"""
echo "running {workers} {processes}"

{mainContent}
"""
  writeFile("./startServer.sh", startServer)
  setFilePermissions("./startServer.sh", {fpUserExec})


#[

--threads:off \
--threadAnalysis:off \
-d:ssl \
-d:release \
-d:danger \
--checks:off \
-d:useMalloc \
-d:useRealtimeGC \
--panics:on \
--gc:orc \

]#
