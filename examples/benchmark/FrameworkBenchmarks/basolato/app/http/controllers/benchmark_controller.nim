import std/algorithm
import std/json
import std/options
import std/random
import std/strutils
import std/sequtils
import std/httpcore
import db_connector/db_postgres
# framework
# import basolato/controller
import ../../../../../../../src/basolato/controller
import allographer/query_builder
import ../../../config/database # rdb, stdRdb, cacheDb
import ../../models/fortune
# import ../views/pages/fortune_view
import ../views/pages/fortune_scf_view


const range1_10000 = 1..10000
let getFirstPrepare = stdRdb.prepare("getFirst", sql""" SELECT * FROM "World" WHERE id = $1 LIMIT 1 """, 1)

proc plaintext*(context:Context, params:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("Content-Type", "text/plain; charset=UTF-8")
  return render("Hello, World!", headers)

proc json*(context:Context, params:Params):Future[Response] {.async.} =
  return render(%*{"message":"Hello, World!"})

proc db*(context:Context, params:Params):Future[Response] {.async.} =
  let i = rand(1..10000)
  let res = stdRdb.getRow(getFirstPrepare, i)
  return render(%*{"id": res[0].parseInt, "randomNumber": res[1].parseInt})


proc query*(context:Context, params:Params):Future[Response] {.async.} =
  var countNum =
    try:
      params.getInt("queries")
    except:
      1
  if countNum < 1:
    countNum = 1
  elif countNum > 500:
    countNum = 500

  var resp:seq[Row]
  for i in 1..countNum:
    let n = rand(range1_10000)
    resp.add(stdRdb.getRow(getFirstPrepare, i))
  let response = resp.map(
    proc(x:seq[string]):JsonNode =
      %*{"id": x[0].parseInt, "randomNumber": x[1]}
    )

  return render(%response)


proc fortune*(context:Context, params:Params):Future[Response] {.async.} =
  let results = stdRdb.getAllRows(sql"""SELECT * FROM "Fortune" ORDER BY message ASC""")
  var rows = results.map(
    proc(x:seq[string]):Fortune =
      return Fortune(id: x[0].parseInt, message: x[1])
  )
  rows.add(
    Fortune(
      id: 0,
      message: "Additional fortune added at request time."
    )
  )
  rows = rows.sortedByIt(it.message)
  return render(fortuneScfView(rows).await)


proc update*(context:Context, params:Params):Future[Response] {.async.} =
  var countNum =
    try:
      params.getInt("queries")
    except:
      1
  if countNum < 1:
    countNum = 1
  elif countNum > 500:
    countNum = 500

  var response = newSeq[JsonNode](countNum)
  var futures = newSeq[Future[void]](countNum)
  for i in 1..countNum:
    let index = rand(range1_10000)
    let number = rand(range1_10000)
    futures[i-1] = (proc():Future[void] {.async.}=
      discard stdRdb.getRow(getFirstPrepare, i)
      rdb.raw(""" UPDATE "World" SET "randomnumber" = ? WHERE id = ? """, %*[number, index]).exec().await
    )()
    response[i-1] = %*{"id":i, "randomNumber": number}
  all(futures).await

  return render(%response)


proc cache*(context:Context, params:Params):Future[Response] {.async.} =
  var countNum =
    try:
      params.getInt("count")
    except:
      1
  if countNum < 1:
    countNum = 1
  elif countNum > 500:
    countNum = 500

  let response = newJArray()
  for i in 1..countNum:
    let id = rand(1..10000)
    let number = rand(1..10000)
    discard cacheDb.table("World").findPlain(id).await
    cacheDb.table("World").where("id", "=", id).update(%*{"randomnumber": number}).await
    response.add(%*{"id":id, "randomNumber": number})

  return render(response)


proc sleep*(context:Context, params:Params):Future[Response] {.async.} =
  sleepAsync(10000).await
  return render("hello")
