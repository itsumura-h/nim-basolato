import std/os
import std/strutils
import std/streams
import std/parsecfg


# Defined in config.nims
const
  SESSION_TYPE* = getEnv("SESSION_TYPE", "file")
  USE_LIBSASS* = when existsEnv("USE_LIBSASS"): getEnv("USE_LIBSASS").parseBool else: false


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
  # Defined in runtime environment valiable
  let
    SECRET_KEY* = getEnv("SECRET_KEY") # Should define in environment variable
    # Session db
    SESSION_DB_PATH* = getEnv("SESSION_DB_PATH", "./session.db")
    # others
    COOKIE_DOMAINS* = getEnv("COOKIE_DOMAIN").split(",")

  if SECRET_KEY.len == 0:
    raise newException(Exception, "SECRET_KEY is not defined in environment variable")

  # Defined in Settings.nim
  var
    # Logging
    LOG_TO_CONSOLE*:bool
    LOG_TO_FILE*:bool
    ERROR_LOG_TO_FILE*:bool
    LOG_DIR*:string
    # Ssession Db
    SESSION_TIME*:int
    SESSION_EXPIRE_ON_CLOSE*:bool
    # others
    LOCALE*:string


type Settings* = object
  host*:string = "127.0.0.1"
  port*:int = 8000
  # Logging
  logToConsole*:bool = true
  logToFile*:bool = false
  errorLogToFile*:bool = false
  logDir*:string = "./logs"
  # Session db
  sessionTime*:int = 120 # default 120, minutes of 2 hours
  sessionExpireOnClose*:bool = false
  # other
  locale*:string = "en"

proc new*(
  _:type Settings,
  host:string = "127.0.0.1",
  port:int = 8000,
  logToConsole:bool = true,
  logToFile:bool = false,
  errorLogToFile:bool = false,
  logDir:string = "./logs",
  sessionTime:int = 120,
  sessionExpireOnClose:bool = false,
  locale:string = "en"
):Settings =
  ## Default values
  ## - `host:string = "127.0.0.1"`
  ## - `port:int = 8000`
  ## - `logToConsole:bool = true`
  ## - `logToFile:bool = false`
  ## - `errorLogToFile:bool = false`
  ## - `logDir:string = "./logs"`
  ## - `sessionTime:int = 120` default 120, minutes of 2 hours
  ## - `sessionExpireOnClose:bool = false`
  ## - `locale:string = "en"`

  LOG_TO_CONSOLE = logToConsole
  LOG_TO_FILE = logToFile
  ERROR_LOG_TO_FILE = errorLogToFile
  LOG_DIR = logDir
  SESSION_TIME = sessionTime
  SESSION_EXPIRE_ON_CLOSE = sessionExpireOnClose
  LOCALE = locale

  return Settings(
    host:host,
    port:port,
    logToConsole:logToConsole,
    logToFile:logToFile,
    errorLogToFile:errorLogToFile,
    logDir:logDir,
    sessionTime:sessionTime,
    sessionExpireOnClose:sessionExpireOnClose,
    locale:locale,
  )
