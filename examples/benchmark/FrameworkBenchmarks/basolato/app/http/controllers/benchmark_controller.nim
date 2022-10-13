import std/algorithm
import std/json
import std/options
import std/random
import std/strutils
import std/sequtils
import std/httpcore
# framework
import basolato/controller
import allographer/query_builder
import ../../../config/database # pgDb, cacheDb
import ../../models/fortune
# import ../views/pages/fortune_view
import ../views/pages/fortune_scf_view


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

  # var response: seq[JsonNode]
  # for i in 1..countNum:
  #   let n = rand(1..10000)
  #   let resp = pgDb.table("World").findPlain(n).await
  #   response.add(%*{"id": resp[0].parseInt, "randomnumber": resp[1]})

  return render(%response)


proc fortune*(context:Context, params:Params):Future[Response] {.async.} =
  let results = pgDb.table("Fortune").orderBy("message", Asc).getPlain().await
  var rows = newSeq[Fortune]()
  for i, data in results:
    rows.add(Fortune(id: data[0].parseInt, message: data[1]))
  rows.add(
    Fortune(
      id: 0,
      message: "Additional fortune added at request time."
    )
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

  let response = newJArray()

  # var proc1 = newSeq[Future[seq[string]]](countNum)
  # var proc2 = newSeq[Future[void]](countNum)
  # for n in 1..countNum:
  #   let i = rand(1..10000)
  #   let newRandomNumber = rand(1..10000)
  #   proc1[n-1] = pgDb.table("World").findPlain(i)
  #   proc2[n-1] = pgDb.table("World").where("id", "=", i).update(%*{"randomNumber": newRandomNumber})
  #   response.add(%*{"id":i, "randomNumber": newRandomNumber})
  # discard all(proc1).await
  # all(proc2).await

  var procs = newSeq[Future[void]](countNum)
  for n in 1..countNum:
    let i = rand(1..10000)
    let newRandomNumber = rand(1..10000)
    procs[n-1] = (proc():Future[void]=
      discard pgDb.table("World").findPlain(i)
      pgDb.table("World").where("id", "=", i).update(%*{"randomNumber": newRandomNumber})
    )()
    response.add(%*{"id":i, "randomNumber": newRandomNumber})
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
