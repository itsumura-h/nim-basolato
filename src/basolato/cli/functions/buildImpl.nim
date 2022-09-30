import os, strformat

proc build*(port="5000", force=false, httpbeast=false, args:seq[string]) =
  ## Build for production.
  var outputFileName = "main"
  let fStr = if force: "-f" else: ""
  let httpbeastStr = if httpbeast: "-d:httpbeast" else: ""
  try:
    outputFileName = args[0]
  except:
    discard

  let cmd = &"""
    nim c \
    {fStr} \
    {httpbeastStr} \
    --gc:orc \
    -d:ssl \
    -d:release \
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