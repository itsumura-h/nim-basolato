import
  std/asyncdispatch,
  std/json,
  std/locks,
  std/options,
  std/osproc,
  std/strformat,
  allographer/query_builder,
  ./environment

proc thread(nThread:int) {.thread.} =
  (proc() {.async.} =
    for i in 1..3:
      withLock(L):
        {.gcsafe.}:
          let res = rdb.table("hello").find(i).await.get
          echo &"スレッド{nThread} {i}回目 {res}"
  )().waitFor


proc main() =
  when compileOption("threads"):
    let countThreads = countProcessors()
    var thr = newSeq[Thread[int]](countThreads)
    for i in 1..countThreads:
      createThread(thr[i-1], thread, i)
    joinThreads(thr)
  else:
    thread(1)

main()
deinitLock(L)
