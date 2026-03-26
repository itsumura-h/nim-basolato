Environment helpers
===
[back](../../README.md)

Table of Contents

<!--ts-->
* [Environment helpers](#environment-helpers)
   * [Introduction](#introduction)
   * [What `env.nim` does](#what-envnim-does)
   * [AppEnv and ServiceEnv](#appenv-and-serviceenv)
   * [Available helpers](#available-helpers)
   * [Typical usage](#typical-usage)
   * [Testing notes](#testing-notes)
   * [Migration notes](#migration-notes)

<!--te-->

## Introduction
`env.nim` is the single entry point for reading environment variables in Basolato.

Its purpose is to keep environment access in one place and make startup fail fast when a required value is missing or invalid.

## What `env.nim` does
The shared implementation lives in [`src/basolato/core/env.nim`](../../src/basolato/core/env.nim).

It provides these responsibilities:

- Load `.env` from the current working directory when the module is imported
- Normalize required environment variables through a single API
- Parse booleans, integers, and other constrained values in one place
- Raise immediately when a required value is missing or malformed

Application-specific modules can then expose typed values on top of it, as shown in [`examples/realworld/config/env.nim`](../../examples/realworld/config/env.nim).

## AppEnv and ServiceEnv
In Basolato, the required environment variables are decided by the combination of `APP_ENV` and `SERVICE_ENV`.

`SERVICE_ENV` defaults to `web-server`. In `realworld`, the `web-server` runtime requires `DB_URL` and `SECRET_KEY` in normal environments, while `APP_ENV=test` can skip those requirements.

If you add another entrypoint later, extend the same matrix instead of scattering `getEnv(...)` checks across the app.

## Available helpers
The current helper set is small on purpose:

- `loadDotEnv(path = getCurrentDir() / ".env")`
- `requireEnv(name: string): string`
- `optionalEnv(name: string, defaultValue: string): string`
- `parseBoolEnv(raw: string): bool`
- `parseIntEnv(name, raw: string): int`
- `parseSessionType(raw: string): SessionType`
- `requireBoolEnv(name: string): bool`
- `optionalBoolEnv(name: string, defaultValue: bool): bool`
- `requireIntEnv(name: string): int`
- `optionalIntEnv(name: string, defaultValue: int): int`

For application-level enums, define a parser in the app config layer and keep the public value typed there.

## Typical usage
Use `requireEnv` for values that must exist before the app can start.

```nim
import std/strutils
import basolato/core/env

type AppEnvType* = enum
  Test = "test"
  Develop = "develop"
  Staging = "staging"
  Production = "production"

type ServiceEnvType* = enum
  WebServer = "web-server"

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

func parseServiceEnv*(raw: string): ServiceEnvType =
  case raw.strip().toLowerAscii()
  of "web-server":
    ServiceEnvType.WebServer
  else:
    raise newException(ValueError, "SERVICE_ENV must be web-server")

let APP_ENV* = parseAppEnv(optionalEnv("APP_ENV", "develop"))
let SERVICE_ENV* = parseServiceEnv(optionalEnv("SERVICE_ENV", "web-server"))

proc isRequiredEnv*(name: string): bool =
  case SERVICE_ENV
  of WebServer:
    case APP_ENV
    of Test:
      false
    of Develop, Staging, Production:
      name in ["DB_URL", "SECRET_KEY"]

proc envValue(name, defaultValue: string): string =
  if isRequiredEnv(name):
    requireEnv(name)
  else:
    optionalEnv(name, defaultValue)

let SECRET_KEY* = envValue("SECRET_KEY", "")
let DB_URL* = envValue("DB_URL", "postgresql://user:pass@postgreDb:5432/database")
```

Then consume those values from application code:

```nim
import ./env
import ./database

if APP_ENV == AppEnvType.Test:
  discard

let rdb* = dbopen(PostgreSQL, DB_URL)
```

## Testing notes
Because `env.nim` can evaluate values during module import, tests should set the required environment variables before importing modules that depend on them.

When a test needs a temporary value, set it explicitly with `putEnv(...)` in the test file or in the test runner command.

## Migration notes
When moving existing code to `env.nim`, prefer this order:

1. Move required values that should fail at startup, such as `SECRET_KEY` and `DB_URL`
2. Replace direct `getEnv(...)` calls with imports from the config env module
3. Add typed parsers only where the value domain is constrained
4. Centralize requiredness with `APP_ENV × SERVICE_ENV`
5. Keep optional defaults only when the default is genuinely safe
