import asyncdispatch
import migration_init

proc main() =
  discard
  init().waitFor()

main()
