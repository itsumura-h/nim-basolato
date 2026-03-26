import std/os
import std/parsecfg
import std/streams
import std/strutils


type SessionType* = enum
  SessionFile = "file"
  SessionRedis = "redis"


proc loadDotEnv*(path = getCurrentDir() / ".env") =
  if not fileExists(path):
    return

  var file = newFileStream(path, fmRead)
  if file.isNil:
    return

  echo("Basolato uses config file '", path, "'")

  var parser: CfgParser
  open(parser, file, path)
  while true:
    let entry = next(parser)
    case entry.kind
    of cfgEof:
      break
    of cfgKeyValuePair:
      putEnv(entry.key, entry.value)
    else:
      discard
  close(parser)


block:
  loadDotEnv()


template requireEnv*(name: string): string =
  ## Raise an error if the environment variable is not defined.
  block:
    let value = getEnv(name).strip()
    if value.len == 0:
      raise newException(ValueError, name & " is not defined in environment variable")
    value


template optionalEnv*(name: string, defaultValue: string): string =
  ## Return the environment variable if it is defined, otherwise return the default value.
  block:
    let value = getEnv(name, defaultValue).strip()
    if value.len == 0:
      defaultValue
    else:
      value


func parseBoolEnv*(raw: string): bool =
  case raw.strip().toLowerAscii()
  of "true", "1", "yes", "on":
    true
  of "false", "0", "no", "off":
    false
  else:
    raise newException(ValueError, "Invalid boolean environment value: " & raw)


func parseSessionType*(raw: string): SessionType =
  case raw.strip().toLowerAscii()
  of "file":
    SessionFile
  of "redis":
    SessionRedis
  else:
    raise newException(ValueError, "SESSION_TYPE must be file|redis")


func parseIntEnv*(name, raw: string): int =
  try:
    return raw.strip().parseInt
  except ValueError:
    raise newException(ValueError, name & " must be an integer: " & raw)


template requireBoolEnv*(name: string): bool =
  parseBoolEnv(requireEnv(name))


template optionalBoolEnv*(name: string, defaultValue: bool): bool =
  parseBoolEnv(optionalEnv(name, if defaultValue: "true" else: "false"))


template requireIntEnv*(name: string): int =
  parseIntEnv(name, requireEnv(name))


template optionalIntEnv*(name: string, defaultValue: int): int =
  parseIntEnv(name, optionalEnv(name, $defaultValue))
