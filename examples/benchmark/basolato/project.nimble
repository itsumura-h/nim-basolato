# Package
version       = "0.1.0"
author        = "Anonymous"
description   = "A new awesome basolato package"
license       = "MIT"
srcDir        = "."
bin           = @["main"]
backend       = "c"
# Dependencies
requires "nim >= 1.4.2"
requires "https://github.com/itsumura-h/nim-basolato >= 0.9.10"
requires "cligen >= 0.9.41"
requires "templates >= 0.5"
requires "bcrypt >= 0.2.1"
requires "flatdb >= 0.2.4"
requires "allographer#feature_replace_async_db"
requires "faker >= 0.13.1"
requires "sass >= 0.1.0"
