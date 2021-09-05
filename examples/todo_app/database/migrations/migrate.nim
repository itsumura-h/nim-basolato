import asyncdispatch
import migration_users

proc main() =
  discard
  waitFor users()

main()
