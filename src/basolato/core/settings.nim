import std/os
import ./env


# Defined in config.nims
const
  SESSION_TYPE* = optionalEnv("SESSION_TYPE", "file")
  USE_LIBSASS* = optionalBoolEnv("USE_LIBSASS", false)

# Defined in runtime environment valiable
when defined(test):
  # Only test, set in compile time.
  const
    SECRET_KEY* = "test_secret_key"
else:
  let
    SECRET_KEY* = requireEnv("SECRET_KEY")


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
  SESSION_PATH*: string = getCurrentDir() / "session.db"
  COOKIE_DOMAINS*: seq[string] = @[]
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
  sessionPath*:string
  cookieDomains*:seq[string]
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
  sessionPath:string = "./session.db",
  cookieDomains:seq[string] = @[],
  locale:string = "en"
):Settings =
  ## Default values
  ## - `host:string = "127.0.0.1"`
  ## - `port:int = 8000`
  ## - `logToConsole:bool = true`
  ## - `logToFile:bool = false`
  ## - `errorLogToFile:bool = false`
  ## - `logDir:string = "./logs"`
  ## - `sessionTime:int = 120` default 120, minutes of 2 hours. If 0, session will not be expired(1 year).
  ## - `sessionExpireOnClose:bool = false`
  ## - `sessionPath:string = "./session.db"`
  ## - `cookieDomains:seq[string] = @[]`
  ## - `locale:string = "en"`

  LOG_TO_CONSOLE = logToConsole
  LOG_TO_FILE = logToFile
  ERROR_LOG_TO_FILE = errorLogToFile
  LOG_DIR = getCurrentDir() / logDir
  SESSION_TIME = sessionTime
  SESSION_EXPIRE_ON_CLOSE = sessionExpireOnClose
  SESSION_PATH = sessionPath
  COOKIE_DOMAINS = cookieDomains
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
    sessionPath:SESSION_PATH,
    cookieDomains:COOKIE_DOMAINS,
    locale:locale,
  )
