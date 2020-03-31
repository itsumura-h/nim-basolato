import migration0001
import migration20200331065251users

proc main() =
  migration0001()
  migration20200331065251users()

main()
