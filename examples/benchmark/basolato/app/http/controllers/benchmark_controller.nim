import json, random, options, cgi, sequtils, algorithm, strutils, times
# framework
import basolato/controller
import allographer/query_builder
from ../../../databases import rdb
import ../views/pages/fortune_view

randomize()

proc json*(request:Request, params:Params):Future[Response] {.async.} =
  return render(%*{"message":"Hello, World!"})

proc plainText*(request:Request, params:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("Content-Type", "text/plain; charset=UTF-8")
  return render("Hello, World!", headers)

proc db*(request:Request, params:Params):Future[Response] {.async.} =
  let i = rand(1..10000)
  let res = await rdb.table("World").findPlain(i)
  return render(%*{"id": res[0].parseInt, "randomNumber": res[1].parseInt})

proc query*(request:Request, params:Params):Future[Response] {.async.} =
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
  let response = newJArray()
  let resp = await all(futures)
  for data in resp:
    response.add(%*{"id": data[0].parseInt, "randomNumber": data[1].parseInt})
  return render(response)

proc fortunes*(request:Request, params:Params):Future[Response] {.async.} =
  let results = await rdb.table("Fortune").orderBy("message", Asc).getPlain()
  var rows = newSeq[JsonNode](results.len+1)
  for i, data in results:
    rows[i] = %*{"id": data[0].parseInt, "message":data[1]}
  rows[results.len] = %*{
    "id": 0,
    "message": "Additional fortune added at request time."
  }
  rows = rows.sortedByIt(it["message"].getStr)
  return render(fortuneView(rows))

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  var countNum =
    try:
      params.getInt("queries")
    except:
      1
  if countNum < 1:
    countNum = 1
  elif countNum > 500:
    countNum = 500

  var futures = newSeq[Future[JsonNode]](countNum)
  for i in 1..countNum:
    futures[i-1] = (proc():Future[JsonNode]{.async.}=
      let n = rand(1..10000)
      let newRandomNumber = rand(1..10000)
      asyncCheck rdb.table("World").findPlain(n)
      await rdb.table("World").where("id", "=", n).update(%*{"randomnumber": newRandomNumber})
      return %*{"id":i, "randomNumber": newRandomNumber}
    )()

  let response = newJArray()
  let resp = await all(futures)
  for data in resp:
    response.add(data)
  return render(response)
