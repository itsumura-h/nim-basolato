import std/os

type AppEnvType* = enum
  Test = "test",
  Develop = "develop",
  Staging = "staging",
  Production = "production"

const
  APP_ENV* = (proc():AppEnvType =
    let env = getEnv("APP_ENV", "develop")
    case env
    of "test": return AppEnvType.Test
    of "develop": return AppEnvType.Develop
    of "staging": return AppEnvType.Staging
    of "production": return AppEnvType.Production
    else: return AppEnvType.Develop
  )()
