import std/strutils
import basolato/core/env


type AppEnvType* = enum
  Test = "test",
  Develop = "develop",
  Staging = "staging",
  Production = "production"

func parseAppEnv*(raw: string): AppEnvType =
  case raw.strip().toLowerAscii()
  of "test":
    AppEnvType.Test
  of "develop":
    AppEnvType.Develop
  of "staging":
    AppEnvType.Staging
  of "production":
    AppEnvType.Production
  else:
    raise newException(ValueError, "APP_ENV must be test|develop|staging|production")


type ServiceEnvType* = enum
  WebServer = "web-server"

func parseServiceEnv*(raw: string): ServiceEnvType =
  case raw.strip().toLowerAscii()
  of "web-server":
    ServiceEnvType.WebServer
  else:
    raise newException(ValueError, "SERVICE_ENV must be web-server")


let APP_ENV* = parseAppEnv(requireEnv("APP_ENV"))
let SERVICE_ENV* = parseServiceEnv(requireEnv("SERVICE_ENV"))


proc isRequiredEnv*(name: string): bool =
  case SERVICE_ENV
  of WebServer:
    case APP_ENV
    of Test:
      name in ["DB_URL"]
    of Develop, Staging, Production:
      name in ["DB_URL", "SECRET_KEY"]


proc envValue(name:string, defaultValue:string=""): string =
  ## Return the environment variable if it is defined, otherwise return the default value.
  ## 
  ## If the environment variable is required, raise an error if it is not defined.
  ## 
  ## If the environment variable is optional, return the default value if it is not defined.
  if isRequiredEnv(name):
    requireEnv(name)
  else:
    optionalEnv(name, defaultValue)


let SECRET_KEY* = envValue("SECRET_KEY")
let DB_URL* = envValue("DB_URL")
