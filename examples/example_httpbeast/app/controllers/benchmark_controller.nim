import asyncdispatch, json, strutils, random
import ../../../../src/basolato_httpbeast/controller
import allographer/query_builder

const range1_10000 = 1..10000
randomize()

proc test1*(request:Request, params:Params):Future[Response] {.async.} =
  await sleepAsync(10000)
  return render("test1")

proc test2*(request:Request, params:Params):Future[Response] {.async.} =
  return render("test2")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  # var countNum =
  #   try:
  #     params.queryParams["queries"].parseInt
  #   except:
  #     1
  var countNum = 500

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
  return render(%response)
