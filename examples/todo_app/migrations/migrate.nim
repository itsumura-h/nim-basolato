import migration0001
import migration20200610090827aaa
import migration20200610090856aaa

proc main() =
  migration0001()
  migration20200610090827aaa()
  migration20200610090856aaa()

main()
