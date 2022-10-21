  import os, strformat

proc build*(port="5000", force=false, httpbeast=false, httpx=false, args:seq[string]) =
  ## Build for production.
  var outputFileName = "main"
  let fStr = if force: "-f" else: ""
  let serverStr = if httpbeast: "-d:httpbeast" elif httpx: "-d:httpx" else: ""

  try:
    outputFileName = args[0]
  except:
    discard

  let cmd = &"""
    nim c \
    {fStr} \
    {serverStr} \
    --threads:off \
    --gc:orc \
    -d:danger \
    -d:ssl \
    -d:release \
    --parallelBuild:0 \
    --passC:"-flto"\
    --passL:"-flto" \
    --panics:on \
    --stackTrace \
    --lineTrace \
    --putenv:PORT={port} \
    --out:{outputFileName} \
    main.nim
  """
  echo cmd
  discard execShellCmd(cmd)

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
