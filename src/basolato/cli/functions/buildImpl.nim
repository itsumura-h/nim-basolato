import std/os
import std/osproc
import std/strformat
import std/strutils
from std/tables import toTable


proc jsBuild() =
  for f in walkDirRec(getCurrentDir(), {pcFile}):
    if f.contains("_script.nim"):
      let parts = f.split(".")
      if parts.len < 2:
        continue
      let jsFilePath = parts[0..^2].join(".")
      let cmd = &"nim js -d:nimExperimentalAsyncjsThen -d:release -o:{jsFilePath}.js {f}"
      echo cmd
      if execCmd(cmd) > 0:
        echo("[FAILED] Build error")
        quit(QuitFailure)


proc build*(workers:uint=0, force=false, httpbeast=false, httpx=false, autoRestart=false, malloc=false, args:seq[string]) =
  ## Build for production.
  jsBuild()
  var outputFileName = "main"
  let fStr = if force: "-f" else: ""
  let serverStr = if httpbeast: "-d:httpbeast" elif httpx: "-d:httpx" else: ""
  let mallocStr = if malloc: "-d:useMalloc" else: ""
  let workers = if workers == 0: countProcessors().uint else: workers

  if args.len > 0:
    outputFileName = args[0]

  var cmd = &"""
    nim c \
    {fStr} \
    {serverStr} \
    {mallocStr} \
    --mm:orc \
    --threads:off \
    -d:ssl \
    -d:danger \
    -d:release \
    --parallelBuild:0 \
    --passC:"-flto" \
    --passL:"-flto" \
    --panics:on \
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
  Historical reference only; production flags are assembled in proc build above.
]#
