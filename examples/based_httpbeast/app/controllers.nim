import
  std/asyncdispatch,
  std/json,
  std/sequtils,
  std/options,
  std/httpcore,
  ../../../src/basolato2/controller,
  allographer/query_builder,
  ../config/database


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  return render("Hello World")

proc error*(context:Context, params:Params):Future[Response] {.async.} =
  return render(Http400, "error")

proc query*(context:Context, params:Params):Future[Response] {.async.} =
  let nThreads = 500
  var futures = newSeq[Future[Option[JsonNode]]](nThreads)
  for i in 1..nThreads:
    futures[i-1] = rdb.table("num_table").find(i)
  let res = all(futures).waitFor()
  let response = res.map(
    proc(x:Option[JsonNode]):JsonNode =
      x.get()
  )
  return render($response)
