# Package

version       = "0.1.0"
author        = "Anonymous"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "."
bin           = @["main"]

backend       = "c"

# Dependencies

requires "nim >= 1.2.0"
requires "basolato >= 0.3.3"
requires "cligen >= 0.9.41"
requires "https://github.com/dom96/jester#4c39652"
requires "templates >= 0.5"
requires "bcrypt >= 0.2.1"
requires "nimAES >= 0.1.2"
requires "https://github.com/enthus1ast/flatdb >= 0.2.4"
requires "allographer >= 0.8.0"
