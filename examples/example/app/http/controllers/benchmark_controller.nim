import std/asyncdispatch
import std/httpcore
import std/json
import std/random
import std/strutils
import std/options
import std/sequtils
import std/algorithm
  # framework
import ../../../../../src/basolato/controller
import allographer/query_builder
import ../../models/fortune
import ../views/pages/benchmark/fortune_view
import ../views/pages/benchmark/fortune_scf_view
from ../../../config/database import pgDb

randomize()

proc plaintext*(context:Context, params:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("Content-Type", "text/plain; charset=UTF-8")
  return render("Hello, World!", headers)

proc json*(context:Context, params:Params):Future[Response] {.async.} =
  return render(%*{"message":"Hello, World!"})

proc db*(context:Context, params:Params):Future[Response] {.async.} =
  let i = rand(1..10000)
  let res = pgDb.table("World").findPlain(i).await
  if res.len > 0:
    return render(%*{"id": res[0].parseInt, "randomNumber": res[1].parseInt})
  else:
    return render(newJObject())
  # let res = pgDb.table("World").find(i).await.get
  # return render(res)


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

  var futures = newSeq[Future[seq[string]]](countNum)
  for i in 1..countNum:
    let n = rand(1..10000)
    futures[i-1] = pgDb.table("World").findPlain(n)
  let resp = all(futures).await
  let response = resp.map(
    proc(x:seq[string]):JsonNode =
      if x.len > 0: %*{"id": x[0].parseInt, "randomnumber": x[1]}
      else: newJObject()
  )
  return render(%response)


proc fortune*(context:Context, params:Params):Future[Response] {.async.} =
  let results = pgDb.table("Fortune").orderBy("message", Asc).getPlain().await
  var rows = newSeq[Fortune]()
  for i, data in results:
    rows.add(Fortune(id: data[0].parseInt, message: data[1]))
  rows.add Fortune(
    id: 0,
    message: "Additional fortune added at request time."
  )
  rows = rows.sortedByIt(it.message)
  # return render(fortuneView(rows).await)
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

  # var proc1 = newSeq[Future[seq[string]]](countNum)
  var procs = newSeq[Future[void]](countNum)
  let response = newJArray()
  for n in 1..countNum:
    let i = rand(1..10000)
    let newRandomNumber = rand(1..10000)
    # proc1[n-1] = pgDb.table("World").findPlain(i)
    # proc2[n-1] = pgDb.table("World").where("id", "=", i).update(%*{"randomnumber": newRandomNumber})
    procs[n-1] = (proc():Future[void]=
      discard pgDb.table("World").findPlain(i)
      pgDb.table("World").where("id", "=", i).update(%*{"randomnumber": newRandomNumber})
    )()
    response.add(%*{"id":i, "randomNumber": newRandomNumber})

  # discard all(proc1).await
  all(procs).await
  return render(response)


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
    let n = rand(1..10000)
    let newRandomNumber = rand(1..10000)
    # discard cacheDb.table("World").findPlain(n).await
    # cacheDb.table("World").where("id", "=", n).update(%*{"randomnumber": newRandomNumber}).await
    response.add(%*{"id":n, "randomNumber": newRandomNumber})

  return render(response)


proc sleep*(context:Context, params:Params):Future[Response] {.async.} =
  sleepAsync(10000).await
  return render("hello")
