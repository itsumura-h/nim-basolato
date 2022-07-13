import os, strutils, streams, parsecfg

const
  SESSION_TYPE* = getEnv("SESSION_TYPE", "file")
  DOES_USE_LIBSASS* = when existsEnv("LIBSASS"): getEnv("LIBSASS").parseBool else: false

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

let
  SECRET_KEY* = getEnv("SECRET_KEY")
  PORT_NUM* = getEnv("PORT", "5000").parseInt
  # Logging
  IS_DISPLAY* = getEnv("LOG_IS_DISPLAY", $true).parseBool
  IS_FILE* = getEnv("LOG_IS_FILE", $true).parseBool
  IS_ERROR_FILE* = getEnv("LOG_IS_ERROR_FILE", $true).parseBool
  LOG_DIR* = getEnv("LOG_DIR", getCurrentDir() / "logs")
  # Session db
  SESSION_DB_PATH* = getEnv("SESSION_DB_PATH", getCurrentDir() / "session.db")
  SESSION_TIME* = getEnv("SESSION_TIME", "20160").parseInt
  COOKIE_DOMAINS* = getEnv("COOKIE_DOMAINS")
  ENABLE_ANONYMOUS_COOKIE* = getEnv("ENABLE_ANONYMOUS_COOKIE", $true).parseBool

  # others
  HOST_ADDR* = getEnv("HOST", "0.0.0.0")
  LOCALE* = getEnv("LOCALE", "en")
