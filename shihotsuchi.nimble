# Package

version       = "0.1.0"
author        = "Hidenobu Itsumura @dumblepytech1 as 'medy'"
description   = "Shihotsuchi a Nim fullstack web framework"
license       = "MIT"
srcDir        = "src"
bin           = @["commands/dbtool"] # ここはパッケージの名前によって変わる
binDir        = "src/bin"
installExt    = @["nim"]
skipDirs      = @["commands"]


# Dependencies

requires "nim >= 1.0.0"
