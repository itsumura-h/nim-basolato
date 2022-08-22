import
  std/asyncdispatch,
  std/json,
  std/options,
  std/strformat,
  allographer/query_builder,
  ./environment

proc controller*(param: (Plugin, int)):Future[void] {.async, gcsafe.} =
  let (plugin, nThread) = param
  for i in 1..3:
    let res = plugin.rdb.table("hello").find(i).await.get
    echo &"スレッド{nThread} {i}回目 {res}"
