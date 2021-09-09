import asyncdispatch
import migration_users
import migration_status
import migration_todo
import migration_groups
import migration_group_user_map

proc main() =
  discard
  waitFor users()
  waitFor groups()
  waitFor group_user_map()
  waitFor status()
  waitFor todo()

main()
