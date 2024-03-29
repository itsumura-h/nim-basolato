import std/os
import std/strutils
import std/streams
import std/parsecfg


const
  SESSION_TYPE* = getEnv("SESSION_TYPE", "file")
  SESSION_DB_PATH* = getEnv("SESSION_DB_PATH", "./session.db")
  DOES_USE_LIBSASS* = when existsEnv("LIBSASS"): getEnv("LIBSASS").parseBool else: false
  HOST_ADDR* = getEnv("HOST", "127.0.0.1")
  PORT_NUM* = getEnv("PORT", "8000").parseInt

for f in walkDir(getCurrentDir()):
  if f.path.split("/")[^1] == ".env":
    let path = getCurrentDir() / ".env"
    var f = newFileStream(path, fmRead)
    echo("Basolato uses config file '", path, "'")
    var p: CfgParser
    open(p, f, path)
    while true:
      var e = next(p)
      case e.kind
      of cfgEof: break
      of cfgKeyValuePair: putEnv(e.key, e.value)
      else: discard
    break

{.cast(gcsafe).}:
  let
    SECRET_KEY* = getEnv("SECRET_KEY")
    # Logging
    IS_DISPLAY* = getEnv("LOG_IS_DISPLAY", $true).parseBool
    IS_FILE* = getEnv("LOG_IS_FILE", $true).parseBool
    IS_ERROR_FILE* = getEnv("LOG_IS_ERROR_FILE", $true).parseBool
    LOG_DIR* = getEnv("LOG_DIR", getCurrentDir() / "logs")
    # Session db
    SESSION_TIME* = getEnv("SESSION_TIME", "120").parseInt
      ## default 120, minutes of 2 hours
    SESSION_EXPIRE_ON_CLOSE* = getEnv("SESSION_EXPIRE_ON_CLOSE", $false).parseBool
    COOKIE_DOMAINS* = getEnv("COOKIE_DOMAINS")

    # others
    LOCALE* = getEnv("LOCALE", "en")
