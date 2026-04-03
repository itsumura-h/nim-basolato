import std/asyncdispatch
import std/algorithm
import std/json
import std/random
import std/strutils
import std/tables
# framework
import basolato/controller
# databse
import allographer/query_builder
import ../../../config/database
# model
import ../../models/fortune
# view
import ../views/pages/fortune_scf_view


const range1_10000 = 1..10000
const worldByIdSql = """SELECT id, randomnumber FROM "World" WHERE id = ?"""
const orderedFortuneSql = """SELECT id, message FROM "Fortune" ORDER BY message ASC"""
const worldUpdateSql = """UPDATE "World" SET randomnumber = ? WHERE id = ?"""
let emptyArgs: seq[string] = @[]

let worldByIdStmt = rdb.prepare(worldByIdSql)
let orderedFortuneStmt = rdb.prepare(orderedFortuneSql)
let worldUpdateStmt = rdb.prepare(worldUpdateSql)

randomize()


proc readCount(context: Context, key: string, defaultVal: int = 1): int =
  var countNum =
    try:
      context.params.getInt(key)
    except:
      defaultVal
  if countNum < 1:
    countNum = 1
  if countNum > 500:
    countNum = 500
  return countNum


proc fetchWorldRow(id: int): Future[seq[string]] {.async.} =
  return await worldByIdStmt.firstPlain(@[$id])


proc fetchFortuneRows(): Future[seq[seq[string]]] {.async.} =
  return await orderedFortuneStmt.getPlain(emptyArgs)


proc plaintext*(context:Context):Future[Response] {.async.} =
  return render("Hello, World!")


proc json*(context:Context):Future[Response] {.async.} =
  return render(%*{"message":"Hello, World!"})


proc db*(context:Context):Future[Response] {.async.} =
  let i = rand(range1_10000)
  let res = fetchWorldRow(i).await
  return render(%*{"id": res[0].parseInt, "randomNumber": res[1].parseInt})


proc query*(context:Context):Future[Response] {.async.} =
  let countNum = readCount(context, "queries")

  var response = newSeq[JsonNode](countNum)
  var futures = newSeq[Future[void]](countNum)
  for i in 0..<countNum:
    let id = rand(range1_10000)
    futures[i] = (
      proc(index: int, id: int):Future[void] {.async.} =
        let row = fetchWorldRow(id).await
        response[index] = %*{"id": row[0].parseInt, "randomNumber": row[1].parseInt}
    )(i, id)

  all(futures).await

  return render(%response)


proc fortune*(context:Context):Future[Response] {.async.} =
  let results = fetchFortuneRows().await

  var rows = newSeq[Fortune](results.len + 1)
  for i, row in results:
    rows[i] = Fortune(id: row[0].parseInt, message: row[1])

  rows[^1] = Fortune(
    id: 0,
    message: "Additional fortune added at request time."
  )

  rows.sort(
    proc(a, b: Fortune): int =
      return cmp(a.message, b.message)
  )

  return render(fortuneScfView(rows).await)


proc update*(context:Context):Future[Response] {.async.} =
  let countNum = readCount(context, "queries")

  var response = newSeq[JsonNode](countNum)
  var futures = newSeq[Future[void]](countNum)

  for i in 0..<countNum:
    let id = rand(range1_10000)
    let randomNumber = rand(range1_10000)

    futures[i] = (proc():Future[void] {.async.} =
      rdb.withConn(
        proc(ctx: PostgresPreparedContext): Future[void] {.async.} =
          discard await worldByIdStmt.firstPlain(ctx, @[$id])
          await worldUpdateStmt.exec(ctx, @[$randomNumber, $id])
      )
    )()
    response[i] = %*{"id": id, "randomNumber": randomNumber}

  all(futures).await

  return render(%response)


var cachedQueryCache = newTable[int, int]()
for i in range1_10000:
  cachedQueryCache[i] = rand(range1_10000)

proc cachedQuery*(context:Context):Future[Response] {.async.} =
  var countNum = readCount(context, "count")

  var response = newSeq[JsonNode](countNum)
  for i in 1..countNum:
    let key = rand(range1_10000)
    response[i-1] = %*{"id": key, "randomNumber": cachedQueryCache[key]}

  return render(%response)
