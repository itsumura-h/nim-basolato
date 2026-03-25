import std/asyncdispatch
import ../../config/env
import ./data/sample_seeder

proc main() {.async.} =
  if APP_ENV == AppEnvType.Production:
    sampleSeeder().await

main().waitFor()
