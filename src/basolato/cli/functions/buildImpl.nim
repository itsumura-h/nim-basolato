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
        -d:ssl \
        --gc:orc \
        --putenv:PORT={port} \
        --out:{outputFileName}{port} \
        main.nim
      """)
  else:
    discard execShellCmd(&"""
      nim c \
      -d:release \
      -d:ssl \
      --gc:orc \
      --putenv:PORT={ports} \
      --out:{outputFileName} \
      --threads:{threads} \
      --threadAnalysis:off \
      main.nim
    """)
