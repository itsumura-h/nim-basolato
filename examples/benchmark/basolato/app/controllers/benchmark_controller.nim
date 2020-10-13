import json, random, algorithm, cgi, sequtils
from strutils import parseInt
# framework
# import basolato/controller
import ../../../../../src/basolato/controller
import allographer/query_builder
# models
import ../models
# repository
import ../repository
# view
import ../../resources/pages/fortune_view
# const
randomize()
const range1_10000 = 1..10000

type BenchmarkController* = ref object of Controller

proc newBenchmarkController*(request:Request):BenchmarkController =
  return BenchmarkController.newController(request)


proc json*(this:BenchmarkController):Response =
  return render(%*{"message":"Hello, World!"})

proc plainText*(this:BenchmarkController):Response =
  var headers = newHeaders()
  headers.set("Content-Type", "text/plain; charset=UTF-8")
  return render("Hello, World!").setHeader(headers)

proc db*(this:BenchmarkController):Response =
  let i = rand(range1_10000)
  let response = rdb().table("world").find(i)
  return render(response)

proc query*(this:BenchmarkController):Response=
  var countNum:int
  try:
    countNum = this.request.params["queries"].parseInt()
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
      response[i-1] = rdb().table("world").find(index)
  return render(%response)

proc fortune*(this:BenchmarkController):Response =
  var rows = rdb().table("Fortune").orderBy("message", Asc).getPlain()
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
  return render(this.view.fortuneView(newRows))

proc update*(this:BenchmarkController):Response =
  var countNum:int
  try:
    countNum = this.request.params["queries"].parseInt()
  except:
    countNum = 1

  if countNum < 1:
    countNum = 1
  elif countNum > 500:
    countNum = 500

  var response = newSeq[JsonNode](countNum)
  let db = db()
  defer: db.close()
  for i in 1..countNum:
    let index = rand(range1_10000)
    let newRandomNumber = rand(range1_10000)
    let repository = newRepository(db)
    repository.findWorld(index)
    repository.updateRandomNumber(index, newRandomNumber)
    response[i-1] = %*{"id":index, "randomNumber": newRandomNumber}
  return render(%response)
