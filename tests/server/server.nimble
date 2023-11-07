# Package

version       = "0.1.0"
author        = "Anonymous"
description   = "A new awesome basolato package"
license       = "MIT"
srcDir        = "."
bin           = @["main"]

backend       = "c"

# Dependencies

requires "nim >= 1.2.0"
requires "basolato >= 0.4.0"
requires "cligen >= 0.9.41"
requires "bcrypt >= 0.2.1"
requires "allographer >= 0.21.0"
requires "faker >= 0.12.1"
