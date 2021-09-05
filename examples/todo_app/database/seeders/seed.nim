import asyncdispatch
import seeder_users

proc main() =
  discard
  waitFor users()

main()
