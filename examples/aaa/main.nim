import
  asyncdispatch,
  json,
  locks,
  # os,
  osproc,
  allographer/query_builder,
  ./environment

proc thread(param:int) {.thread.} =
  let rdb = initDb()
  (proc() {.async.} =
    for i in 1..param:
      {.gcsafe.}:
        echo rdb.table("World").first().await
  )().waitFor


proc main() =
  when compileOption("threads"):
    let numThreads = countProcessors()
    var thr = newSeq[Thread[int]](numThreads)
    for i in 1..numThreads:
      createThread(thr[i-1], thread, numThreads)
    joinThreads(thr)
  else:
    thread(1)

main()
