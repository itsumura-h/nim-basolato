import os, strformat

proc build*(port="5000", f=false, httpbeast=false, args:seq[string]) =
  ## Build for production.
  var outputFileName = "main"
  let fStr = if f: "-f" else: ""
  let httpbeastStr = if httpbeast: "-d:httpbeast" else: ""
  try:
    outputFileName = args[0]
  except:
    discard

  discard execShellCmd(&"""
    nim c \
    {fStr} \
    {httpbeastStr} \
    --threads:off \
    --gc:orc \
    -d:ssl \
    -d:release \
    --panics:on \
    --stackTrace \
    --lineTrace \
    --putenv:PORT={port} \
    --out:{outputFileName} \
    main.nim
  """)

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