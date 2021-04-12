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
        --putenv:PORT={port} \
        main.nim
      """)
  else:
    discard execShellCmd(&"""
      nim c \
      -d:release \
      --threads:{threads} \
      --threadAnalysis:off \
      --out:{outputFileName} \
      --putenv:PORT={ports} \
      main.nim
    """)
