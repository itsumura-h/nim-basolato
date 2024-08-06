# Package

version       = "0.15.0"
author        = "Hidenobu Itsumura @dumblepytech1 as 'medy'"
description   = "A full-stack web framework for Nim"
license       = "MIT"
srcDir        = "src"
backend       = "c"
bin           = @["basolato/cli/ducere"]
binDir        = "src/bin"
installExt    = @["nim"]
skipDirs      = @["basolato/cli"]

# Dependencies

requires "nim >= 1.6.12"
requires "interface_implements >= 0.2.2"
requires "httpbeast >= 0.4.1"
requires "httpx >= 0.3.0"
requires "bcrypt >= 0.2.1"
requires "cligen >= 1.5.9"
requires "redis >= 0.3.0"
requires "sass >= 0.1.0"
requires "nimcrypto >= 0.6.0"

when NimMajor == 2:
  requires "checksums >= 0.1.0"


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
