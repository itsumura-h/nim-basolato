import os, strformat, strutils

proc build*(ports="5000", threads=false, args:seq[string]) =
  ## Build for production.
  var outputFileName = "main"
  let threadsBool = if threads:"on" else: "off"
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
      --threads:{threadsBool} \
      --threadAnalysis:off \
      main.nim
    """)
