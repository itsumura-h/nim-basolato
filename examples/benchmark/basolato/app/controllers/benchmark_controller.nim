import json, random, algorithm, cgi, sequtils, strutils
# framework
import basolato/controller
import allographer/query_builder
# model
import ../domain/models/fortune/fortune_entity
# view
import ../../resources/pages/fortune_view
# const
randomize()
const range1_10000 = 1..10000

proc json*(request:Request, params:Params):Future[Response] {.async.} =
  return render(%*{"message":"Hello, World!"})

proc plainText*(request:Request, params:Params):Future[Response] {.async.} =
  var headers = newHeaders()
  headers.set("Content-Type", "text/plain; charset=UTF-8")
  return render("Hello, World!", headers)

proc db*(request:Request, params:Params):Future[Response] {.async.} =
  let i = rand(1..10000)
  let response = await rdb().table("World").select("id", "randomNumber").asyncFind(i)
  return render(%*response)

proc query*(request:Request, params:Params):Future[Response] {.async.} =
  var countNum =
    try:
      params.queryParams["queries"].parseInt
    except:
      1

  if countNum < 1:
    countNum = 1
  elif countNum > 500:
    countNum = 500

  var response = newJArray()
  for _ in 1..countNum:
    let i = rand(1..10000)
    let data = await rdb().table("World").select("id", "randomNumber").asyncFind(i)
    response.add(data)
  return render(%*response)

proc fortune*(request:Request, params:Params):Future[Response] {.async.} =
  var rows = await rdb().table("Fortune").select("id", "message").orderBy("message", Asc).asyncGetPlain()
  var newRows = rows.mapIt(
    Fortune(
      id: it[0].parseInt,
      message: xmlEncode(it[1])
    )
  )
  newRows.add(
    Fortune(
      id:0,
      message:"Additional fortune added at request time."
    )
  )
  newRows = newRows.sortedByIt(it.message)
  return render(fortuneView(newRows))

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  echo "=== update start"
  var countNum =
    try:
      params.queryParams["queries"].parseInt
    except:
      1

  if countNum < 1:
    countNum = 1
  elif countNum > 500:
    countNum = 500

  var response = newSeq[JsonNode](countNum)
  var getFutures = newSeq[Future[Row]](countNum)
  var updateFutures = newSeq[Future[void]](countNum)
  for i in 1..countNum:
    let index = rand(range1_10000)
    let number = rand(range1_10000)
    getFutures[i-1] = rdb().table("World").select("id", "randomNumber").asyncFindPlain(index)
    updateFutures[i-1] = rdb()
                        .table("World")
                        .where("id", "=", index)
                        .asyncUpdate(%*{"randomNumber": number})
    response[i-1] = %*{"id":index, "randomNumber": number}

  try:
    discard await all(getFutures)
    await all(updateFutures)
  except:
    discard
  echo "=== update end"
  return render(%response)
