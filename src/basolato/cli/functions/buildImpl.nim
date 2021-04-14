import os, strformat, strutils

proc build*(ports="5000", threads="off", args:seq[string]) =
  ## Build for production.
  var outputFileName = "main"
  try:
    outputFileName = args[0]
  except:
    discard

  if ports.contains(","):
    for port in ports.split(","):
      let port = port.strip
      discard execShellCmd(&"""
        nim c \
        -d:release \
        --out:{outputFileName}{port} \
        --gc:orc \
        --putenv:PORT={port} \
        main.nim
      """)
  else:
    discard execShellCmd(&"""
      nim c \
      -d:release \
      --threads:{threads} \
      --gc:orc \
      --out:{outputFileName} \
      --putenv:PORT={ports} \
      main.nim
    """)

    # --threadAnalysis:off \
