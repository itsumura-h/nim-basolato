from strutils import parseInt
import json, random
# framework
import basolato/controller
import allographer/query_builder


type BenchmarkController* = ref object of Controller

proc newBenchmarkController*(request:Request):BenchmarkController =
  return BenchmarkController.newController(request)


proc plainText*(this:BenchmarkController):Response =
  return render("plainText")

proc jsonAccess*(this:BenchmarkController):Response =
  return render(%*{"message": "Hello, World!"})

proc dbAccess*(this:BenchmarkController):Response =
  randomize()
  let i = rand(1..10000)
  let r = RDB().table("world").find(i)
  return render(r)

proc queryAccess*(this:BenchmarkController, queries="1"):Response =
  var queries = queries.parseInt()
  if queries < 1:
    queries = 1
  elif queries > 500:
    queries = 500

  randomize()
  var response = newJArray()
  for i in 0..queries:
    let id = rand(1..10000)
    response.add(RDB().table("world").find(id))
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
