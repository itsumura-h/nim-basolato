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


let APP_ENV* = parseAppEnv(optionalEnv("APP_ENV", "develop"))
let SECRET_KEY* = requireEnv("SECRET_KEY")
let DB_URL* = requireEnv("DB_URL")
