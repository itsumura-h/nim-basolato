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
    --threads:off \
    -d:release \
    -d:danger \
    --checks:off \
    -d:ssl \
    --gc:orc \
    --putenv:PORT={port} \
    --out:{outputFileName} \
    --threadAnalysis:off \
    main.nim
  """)
