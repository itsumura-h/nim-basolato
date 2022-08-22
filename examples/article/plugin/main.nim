import
  std/asyncdispatch,
  std/osproc,
  std/sequtils,
  ./environment,
  ./controller

proc thread(param:(Plugin, int)) {.thread.} =
  (proc() {.async.} =
    await controller.controller(param)
  )().waitFor


proc main(plugins:seq[Plugin]) =
  when compileOption("threads"):
    let countThreads = countProcessors()
    var thr = newSeq[Thread[(Plugin, int)]](countThreads)
    for i in 0..countThreads-1:
      createThread(thr[i], thread, (plugins[i], i+1))
    joinThreads(thr)
  else:
    thread((plugins[0], 1))

var plugins = newSeq[Plugin](countProcessors())
for i in 0..countProcessors()-1:
  plugins[i] = Plugin(
    rdb:initDb()
  ) 
main(plugins)
