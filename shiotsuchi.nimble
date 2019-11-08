# Package

version       = "0.1.0"
author        = "Hidenobu Itsumura @dumblepytech1 as 'medy'"
description   = "Shiotsuchi a Nim fullstack web framework"
license       = "MIT"
srcDir        = "src"
bin           = @["cli/web"] # ここはパッケージの名前によって変わる
binDir        = "src/bin"
installExt    = @["nim"]
skipDirs      = @["cli/shiotsuchi"]


# Dependencies

requires "nim >= 1.0.0"
requires "cligen >= 0.9.41"
requires "jester >= 0.4.3"
requires "templates >= 0.5"