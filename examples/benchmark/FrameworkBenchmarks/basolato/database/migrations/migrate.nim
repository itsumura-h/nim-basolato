import asyncdispatch
import migration_init

proc main() =
  discard
  waitFor init()

main()
