import std/asyncdispatch
import std/algorithm
import std/json
import std/random
import std/strutils
import std/sequtils
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


proc plaintext*(context:Context):Future[Response] {.async.} =
  return render("Hello, World!")


proc json*(context:Context):Future[Response] {.async.} =
  return render(%*{"message":"Hello, World!"})


proc db*(context:Context):Future[Response] {.async.} =
  let i = rand(1..10000)
  let res = rdb.table("World").findPlain(i).await
  return render(%*{"id": res[0].parseInt, "randomNumber": res[1].parseInt})


proc query*(context:Context):Future[Response] {.async.} =
  var countNum =
    try:
      context.params.getInt("queries")
    except:
      1
  if countNum < 1:
    countNum = 1
  elif countNum > 500:
    countNum = 500

  var resp:seq[JsonNode]
  for i in 1..countNum:
    let n = rand(range1_10000)
    let res = rdb.table("World").findPlain(n).await
    resp.add(%*{"id": res[0].parseInt, "randomNumber": res[1].parseInt})

  return render(%resp)


proc fortune*(context:Context):Future[Response] {.async.} =
  let results = rdb.table("Fortune").orderBy("message", Asc).getPlain().await
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


proc update*(context:Context):Future[Response] {.async.} =
  var countNum =
    try:
      context.params.getInt("queries")
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
    response[i-1] = %*{"id": index, "randomNumber": number}
    futures[i-1] = (
      proc():Future[void] {.async.} =
        discard rdb.table("World").findPlain(index).await
        rdb.table("World").where("id", "=", index).update(%*{"randomnumber": number}).await
    )()
  all(futures).await

  return render(%response)
