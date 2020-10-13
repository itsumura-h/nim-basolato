import json, random, algorithm, cgi, sequtils, strutils
# framework
import basolato/controller
import allographer/query_builder
# model
import ../domain/models/fortune/fortune_entity
import ../domain/models/world/world_repository_interface
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
  let i = rand(range1_10000)
  let response = await rdb().table("world").asyncFind(i)
  return render(response)

proc query*(request:Request, params:Params):Future[Response] {.async.} =
  var countNum:int
  try:
    countNum = params.urlParams["queries"].getInt
  except:
    countNum = 1

  if countNum < 1:
    countNum = 1
  elif countNum > 500:
    countNum = 500

  var response = newSeq[JsonNode](countNum)
  transaction:
    for i in 1..countNum:
      let index = rand(1..10000)
      response[i-1] = await rdb().table("world").asyncFind(index)
  return render(%response)

proc fortune*(request:Request, params:Params):Future[Response] {.async.} =
  var rows = await rdb().table("Fortune").orderBy("message", Asc).asyncGetPlain()
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
  var countNum:int
  try:
    countNum = params.requestParams.get("queries").parseInt()
  except:
    countNum = 1

  if countNum < 1:
    countNum = 1
  elif countNum > 500:
    countNum = 500

  var response = newSeq[JsonNode](countNum)
  for i in 1..countNum:
    let index = rand(range1_10000)
    let newRandomNumber = rand(range1_10000)
    let repository = newIWorldRepository()
    await repository.findWorld(index)
    await repository.updateRandomNumber(index, newRandomNumber)
    response[i-1] = %*{"id":index, "randomNumber": newRandomNumber}
  return render(%response)
