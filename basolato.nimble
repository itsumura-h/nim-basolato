# Package

version       = "0.11.2"
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

requires "nim >= 1.4.0"
requires "allographer >= 0.19.2"
# requires "allographer#head"
requires "interface_implements >= 0.2.2"
requires "bcrypt >= 0.2.1"
requires "cligen >= 1.5.9"
requires "dotenv >= 1.1.1"
requires "faker >= 0.14.0"
requires "flatdb >= 0.2.5"
requires "nimAES >= 0.1.2"
requires "redis >= 0.3.0"
requires "sass >= 0.1.0"
requires "templates >= 0.5"

import strformat, os

# task docs, "Generate API documents":
#   let
#     deployDir = "deploy" / "docs"
#     pkgDir = srcDir / "basolato"
#     srcFiles = @[
#       "controller", "middleware", "password", "request_validation", "view",
#     ]

#   if existsDir(deployDir):
#     rmDir deployDir
#   for f in srcFiles:
#     let srcFile = pkgDir / f & ".nim"
#     exec &"nim doc --hints:off --project --out:{deployDir} --index:on {srcFile}"

task install, "install":
  discard
after install:
  # https://aa.be-dama.com
  echo "    _   ________  ___"
  echo "   / | / /  _/  |/  /"
  echo "  /  |/ // // /|_/ / "
  echo " / /|  // // /  / /  "
  echo "/_/ |_/___/_/  /_/   "
  echo "    ____  ___   _____ ____  __    ___  __________ "
  echo "   / __ )/   | / ___// __ \\/ /   /   |/_  __/ __ \\"
  echo "  / __  / /| | \\__ \\/ / / / /   / /| | / / / / / /"
  echo " / /_/ / ___ |___/ / /_/ / /___/ ___ |/ / / /_/ / "
  echo "/_____/_/  |_/____/\\____/_____/_/  |_/_/  \\____/  "
  echo "    __________  ___    __  __________       ______  ____  __ __"
  echo "   / ____/ __ \\/   |  /  |/  / ____/ |     / / __ \\/ __ \\/ //_/"
  echo "  / /_  / /_/ / /| | / /|_/ / __/  | | /| / / / / / /_/ / ,<   "
  echo " / __/ / _, _/ ___ |/ /  / / /___  | |/ |/ / /_/ / _, _/ /| |  "
  echo "/_/   /_/ |_/_/  |_/_/  /_/_____/  |__/|__/\\____/_/ |_/_/ |_|  "
  echo ""

let toolImage = "basolato:tool"

task setupTool, "Setup tool docker image":
  exec &"docker build -t {toolImage} -f ./docker/tool/Dockerfile ."

proc generateToc(dir: string) =
  let cwd = getCurrentDir()
  for f in listFiles(dir):
    if 3 < f.len:
      let ext = f[^3..^1]
      if ext == ".md":
        exec &"docker run --rm -v {cwd}:/work -it {toolImage} --insert --no-backup {f}"

task toc, "Generate TOC":
  generateToc(".")
  generateToc("./documents/en")
  generateToc("./documents/ja")
