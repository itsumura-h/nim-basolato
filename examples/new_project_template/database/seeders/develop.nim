import std/asyncdispatch
import ../../config/env
import ./data/sample_seeder

proc main() {.async.} =
  if APP_ENV == AppEnvType.Develop or APP_ENV == AppEnvType.Test:
    sampleSeeder().await

main().waitFor()
