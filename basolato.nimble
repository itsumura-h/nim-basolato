# Package

version       = "0.1.0"
author        = "Hidenobu Itsumura @dumblepytech1 as 'medy'"
description   = "A fullstack web framework library for Nim"
license       = "MIT"
srcDir        = "src"
backend       = "c"
bin           = @["cli/ducere"]
binDir        = "src/bin"
installExt    = @["nim"]
skipDirs      = @["cli"]


# Dependencies

requires "nim >= 1.0.0"
requires "cligen >= 0.9.41"
requires "jester >= 0.4.3"
requires "templates >= 0.5"