from strutils import parseInt
import json, random
# framework
import basolato/controller
import allographer/query_builder


type BenchmarkController* = ref object of Controller

proc newBenchmarkController*(request:Request):BenchmarkController =
  return BenchmarkController.newController(request)


proc plainText*(this:BenchmarkController):Response =
  var header = newHeaders()
  header.set("Content-Type", "text/plain; charset=UTF-8")
  return render("Hello, World!").setHeader(header)

proc jsonAccess*(this:BenchmarkController):Response =
  var header = newHeaders()
  header.set("Content-Type", "application/json; charset=UTF-8")
  return render(%*{"message": "Hello, World!"}).setHeader(header)

proc dbAccess*(this:BenchmarkController):Response =
  randomize()
  let i = rand(1..10000)
  let r = RDB().table("world").find(i)
  return render(%*{"id": i, "randomNumber": r["randomnumber"].getInt})

proc queryAccess*(this:BenchmarkController):Response =
  var queries:int
  try:
    queries = this.request.params["queries"].parseInt
  except:
    queries = 1
  if queries < 1:
    queries = 1
  elif queries > 500:
    queries = 500

  randomize()
  var response = newJArray()
  for i in 1..queries:
    let id = rand(1..10000)
    let dbData = RDB().table("world").find(id)
    response.add(%*{"id": dbData["id"].getInt, "randomnumber": dbData["randomnumber"].getInt})
  return render(response)

proc index*(this:BenchmarkController):Response =
  return render("index")

proc show*(this:BenchmarkController, id:string):Response =
  let id = id.parseInt
  return render("show")

proc create*(this:BenchmarkController):Response =
  return render("create")

proc store*(this:BenchmarkController):Response =
  return render("store")

proc edit*(this:BenchmarkController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:BenchmarkController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:BenchmarkController, id:string):Response =
  let id = id.parseInt
  return render("destroy")
