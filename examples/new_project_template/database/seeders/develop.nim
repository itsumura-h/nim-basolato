import std/asyncdispatch
import ./data/sample_seeder

proc main() {.async.} =
  sampleSeeder().await

main().waitFor()
