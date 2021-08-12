import json, options, random, times
# framework
import basolato/controller
import basolato/core/base
# view
import ../views/pages/welcome_view
# db
from ../../../databases import rdb
import allographer/query_builder

randomize()

proc dbInfo() =
  echo "=== rdb"
  echo $now()
  echo rdb.pools[0].postgresConn.status.repr
  echo rdb.pools[1].postgresConn.status.repr
  echo rdb.pools[2].postgresConn.status.repr

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let s = cpuTime()
  var futures = newSeq[Future[seq[JsonNode]]](10)
  const sql = "select pg_sleep(10)"
  # const sql = "select id, randomNumber from \"World\""
  dbInfo()

  for i in 0..<10:
    futures[i] = rdb.raw(sql).getRaw()
  let resp = await all(futures)
  dbInfo()

  let time = cpuTime() - s
  return render(%*{"time":time, "timestamp": $(now().utc())})

proc indexApi*(request:Request, params:Params):Future[Response] {.async.} =
  let name = "Basolato " & basolatoVersion
  return render(%*{"message": "Basolato " & basolatoVersion})
