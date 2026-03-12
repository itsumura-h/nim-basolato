# Package
version       = "0.1.0"
author        = "Anonymous"
description   = "A new awesome basolato package"
license       = "MIT"
srcDir        = "."
bin           = @["main"]
backend       = "c"
# Dependencies
requires "nim >= 2.0.0"
requires "https://github.com/itsumura-h/nim-basolato >= 0.15.0"
requires "allographer >= 0.21.0"
requires "interface_implements >= 0.2.2"
requires "faker >= 0.14.0"

task test, "run testament":
  echo staticExec("testament p \"./tests/test_*.nim\"")
  discard staticExec("find tests/ -type f ! -name \"*.*\" -delete 2> /dev/null")
