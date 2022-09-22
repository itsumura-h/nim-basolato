import
  std/algorithm,
  std/json,
  std/options,
  std/random,
  std/strutils
# framework
import basolato/controller
import allographer/query_builder
import ../../../config/database # rdb, cacheDb
import ../views/pages/fortune_view


proc json*(context:Context, params:Params):Future[Response] {.async.} =
  return render(%*{"message":"Hello, World!"})


proc plainText*(context:Context, params:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("Content-Type", "text/plain; charset=UTF-8")
  return render("Hello, World!", headers)


proc db*(context:Context, params:Params):Future[Response] {.async.} =
  let i = rand(1..10000)
  let res = rdb.table("World").findPlain(i).await
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

  var futures = newSeq[Future[seq[string]]](countNum)
  for i in 1..countNum:
    let n = rand(1..10000)
    futures[i-1] = rdb.table("World").findPlain(n)
  let resp = all(futures).await
  var response = newSeq[JsonNode](resp.len)
  for i, data in resp:
    response[i-1] = %*{"id": data[0].parseInt, "randomNumber": data[1].parseInt}
  return render(%response)


proc fortunes*(context:Context, params:Params):Future[Response] {.async.} =
  let results = rdb.table("Fortune").orderBy("message", Asc).getPlain().await
  var rows = newSeq[JsonNode](results.len+1)
  for i, data in results:
    rows[i] = %*{"id": data[0].parseInt, "message":data[1]}
  rows[results.len] = %*{
    "id": 0,
    "message": "Additional fortune added at request time."
  }
  rows = rows.sortedByIt(it["message"].getStr)
  return render(fortuneView(rows).await)


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

  var proc1 = newSeq[Future[seq[string]]](countNum)
  var proc2 = newSeq[Future[void]](countNum)
  let response = newJArray()
  for n in 1..countNum:
    let i = rand(1..10000)
    let newRandomNumber = rand(1..10000)
    proc1[n-1] = rdb.table("World").findPlain(i)
    proc2[n-1] = rdb.table("World").where("id", "=", i).update(%*{"randomnumber": newRandomNumber})
    response.add(%*{"id":i, "randomNumber": newRandomNumber})

  discard all(proc1).await
  all(proc2).await
  return render(response)


proc cached*(context:Context, params:Params):Future[Response] {.async.} =
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
    discard cacheDb.table("World").findPlain(n).await
    cacheDb.table("World").where("id", "=", n).update(%*{"randomnumber": newRandomNumber}).await
    response.add(%*{"id":i, "randomNumber": newRandomNumber})

  return render(response)
