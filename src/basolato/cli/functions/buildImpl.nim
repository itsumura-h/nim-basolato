import os, strformat

proc build*(port="5000", args:seq[string]) =
  ## Build for production.
  var outputFileName = "main"
  try:
    outputFileName = args[0]
  except:
    discard

  discard execShellCmd(&"""
    nim c \
    -f \
    --threads:off \
    --threadAnalysis:off \
    -d:ssl \
    -d:release \
    -d:danger \
    --checks:off \
    -d:useMalloc \
    -d:useRealtimeGC \
    --gc:orc \
    --putenv:PORT={port} \
    --out:{outputFileName} \
    main.nim
  """)
