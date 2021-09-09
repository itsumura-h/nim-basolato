import asyncdispatch
import seeder_users
import seeder_status
import seeder_todo
import seeder_groups
import seeder_group_user_map

proc main() =
  discard
  waitFor users()
  waitFor groups()
  waitFor group_user_map()
  waitFor status()
  waitFor todo()

main()
