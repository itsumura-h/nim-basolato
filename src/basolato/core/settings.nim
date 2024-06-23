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
  when defined(test):
    # Only test, set in compile time.
    const
      SECRET_KEY* = "test_secret_key"
      SESSION_DB_PATH* = getEnv("SESSION_DB_PATH", "./session.db")
  else:
    let
      SECRET_KEY* = getEnv("SECRET_KEY")
      SESSION_DB_PATH* = getEnv("SESSION_DB_PATH", "./session.db")
      COOKIE_DOMAINS* = getEnv("COOKIE_DOMAIN").split(",")

    if SECRET_KEY.len == 0:
      raise newException(Exception, "SECRET_KEY is not defined in environment variable")


  # Defined in Settings.nim
  var
    # Logging
    LOG_TO_CONSOLE*:bool = true
    LOG_TO_FILE*:bool = false
    ERROR_LOG_TO_FILE*:bool = false
    LOG_DIR*:string = "./logs"
    # Ssession Db
    SESSION_TIME*:int = 120  # default 120, minutes of 2 hours
    SESSION_EXPIRE_ON_CLOSE*:bool = false
    # others
    LOCALE*:string = "en"


type Settings* = object
  host*:string
  port*:int
  # Logging
  logToConsole*:bool
  logToFile*:bool
  errorLogToFile*:bool
  logDir*:string
  # Session db
  sessionTime*:int
  sessionExpireOnClose*:bool
  # other
  locale*:string

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
  LOG_DIR = getCurrentDir() / logDir
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
