# Package

version       = "0.8.1" # https://github.com/itsumura-h/nim-basolato/issues/87
author        = "Hidenobu Itsumura @dumblepytech1 as 'medy'"
description   = "A full-stack web framework library for Nim"
license       = "MIT"
srcDir        = "src"
backend       = "c"
bin           = @["basolato/cli/ducere"]
binDir        = "src/bin"
installExt    = @["nim"]
skipDirs      = @["basolato/cli"]

# Dependencies

requires "nim >= 1.0.0"
requires "cligen >= 0.9.41"
requires "templates >= 0.5"
requires "bcrypt >= 0.2.1"
requires "nimAES >= 0.1.2"
requires "flatdb >= 0.2.4"
requires "allographer >= 0.13.0"
requires "faker >= 0.13.1"

import strformat
# from os import `/`

# task docs, "Generate API documents":
#   let
#     deployDir = "deploy" / "docs"
#     pkgDir = srcDir / "basolato"
#     srcFiles = @[
#       "base","controller","logger","middleware","routing","view"
#     ]

#   if existsDir(deployDir):
#     rmDir deployDir
#   for f in srcFiles:
#     let srcFile = pkgDir / f & ".nim"
#     exec &"nim doc --hints:off --project --out:{deployDir} --index:on {srcFile}"

task install, "install":
  discard
after install:
  echo ""
  echo "███╗   ███╗  █████╗  ███╗   ███╗"
  echo "████╗  ███║   ███╔╝  ████╗ ████║"
  echo "██╔███╗███║   ███║   ██╔████╔██║"
  echo "██║╚══████║   ███║   ██║╚██╔╝██║"
  echo "██║   ╚███║  █████╗  ██║ ╚═╝ ██║"
  echo "╚═╝     ╚═╝  ╚════╝  ╚═╝     ╚═╝"
  echo "████████╗     █╗     ███████╗  ███████╗ ██╗           █╗    █████████╗ ███████╗ "
  echo "██╔════██╗   █╔█╗   ██╔═════╝ ██╔════██╗██║          █╔█╗      ███╔══╝██╔════██╗"
  echo "████████╔╝  █╔╝ █╗   ███████╗ ██║    ██║██║         █╔╝ █╗     ███║   ██║    ██║"
  echo "██╔════██╗ ███████╗  ╚═════██╗██║    ██║██║        ███████╗    ███║   ██║    ██║"
  echo "████████╔╝██╔════██╗ ███████╔╝ ███████╔╝█████████╗██╔════██╗   ███║    ███████╔╝"
  echo "╚═══════╝ ╚═╝    ╚═╝ ╚══════╝  ╚══════╝ ╚════════╝╚═╝    ╚═╝   ╚══╝    ╚══════╝ "
  echo "█████████╗████████╗     █╗    ███╗   ███╗█████████╗██╗    ██╗ ███████╗ ████████╗ ██╗    ██╗"
  echo "██╔══════╝██╔════██╗   █╔█╗   ████╗ ████║██╔══════╝██║    ██║██╔════██╗██╔════██╗██║  ██╔═╝"
  echo "█████████╗████████╔╝  █╔╝ █╗  ██╔████╔██║█████████╗██║ █╗ ██║██║    ██║████████╔╝██████╔╝  "
  echo "██╔══════╝██╔═══██║  ███████╗ ██║╚██╔╝██║██╔══════╝██║███╗██║██║    ██║██╔═══██║ ██╔═══██╗ "
  echo "██║       ██║    ██╗██╔════██╗██║ ╚═╝ ██║█████████╗╚███╔███╔╝ ███████╔╝██║    ██╗██║    ██╗"
  echo "╚═╝       ╚═╝    ╚═╝╚═╝    ╚═╝╚═╝     ╚═╝╚════════╝ ╚══╝╚══╝  ╚══════╝ ╚═╝    ╚═╝╚═╝    ╚═╝"
  echo ""

let toolImage = "basolato:tool"

task setupTool, "Setup tool docker image":
  exec &"docker build -t {toolImage} -f tool_Dockerfile ."

proc generateToc(dir: string) =
  let cwd = getCurrentDir()
  for f in listFiles(dir):
    if 3 < f.len:
      let ext = f[^3..^1]
      if ext == ".md":
        exec &"docker run --rm -v {cwd}:/work -it {toolImage} --insert --no-backup {f}"

task toc, "Generate TOC":
  generateToc(".")
  generateToc("./documents")
