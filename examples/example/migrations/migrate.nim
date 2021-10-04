import asyncdispatch
import migration20210901235644users

proc main() =
  discard
  waitFor migration20210901235644users()

main()
