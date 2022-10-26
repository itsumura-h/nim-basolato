import std/algorithm
import std/json
import std/options
import std/random
import std/strutils
import std/sequtils
import std/httpcore
# framework
# import basolato/controller
import ../../../../../../../src/basolato/controller
import allographer/query_builder
import ../../../config/database # pgDb, cacheDb
import ../../models/fortune
# import ../views/pages/fortune_view
import ../views/pages/fortune_scf_view

import db_postgres


proc plaintext*(context:Context, params:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("Content-Type", "text/plain; charset=UTF-8")
  return render("Hello, World!", headers)

proc json*(context:Context, params:Params):Future[Response] {.async.} =
  return render(%*{"message":"Hello, World!"})

proc sleep*(context:Context, params:Params):Future[Response] {.async.} =
  sleepAsync(10000).await
  return render("hello")

proc db*(context:Context, params:Params):Future[Response] {.async.} =
  let i = rand(1..10000)
  let res = stdPg.getRow(sql""" SELECT * FROM "World" WHERE id = ? LIMIT 1""", i)
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

  var resp:seq[Row]
  for i in 1..countNum:
    let n = rand(1..10000)
    resp.add(stdPg.getRow(sql"""SELECT * FROM "World" WHERE id = ? LIMIT 1""", n))
  let response = resp.map(
    proc(x:seq[string]):JsonNode =
      %*{"id": x[0].parseInt, "randomNumber": x[1]}
    )

  return render(%response)


proc fortune*(context:Context, params:Params):Future[Response] {.async.} =
  let results = stdPg.getAllRows(sql"""SELECT * FROM "Fortune" ORDER BY message ASC""")
  var rows = results.map(
    proc(x:seq[string]):Fortune =
      return Fortune(id: x[0].parseInt, message: x[1])
  )
  rows.add(
    Fortune(
      id: 0,
      message: "Additional fortune added at request time."
    )
  )
  rows = rows.sortedByIt(it.message)
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
  var procs = newSeq[Future[void]](countNum)
  for n in 1..countNum:
    let i = rand(1..10000)
    let newRandomNumber = rand(1..10000)
    procs[n-1] = (proc():Future[void]=
      discard pgDb.table("World").findPlain(i)
      pgDb.table("World").where("id", "=", i).update(%*{"randomnumber": newRandomNumber})
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
    discard cacheDb.table("World").findPlain(n).await
    cacheDb.table("World").where("id", "=", n).update(%*{"randomNumber": newRandomNumber}).await
    response.add(%*{"id":n, "randomNumber": newRandomNumber})

  return render(response)
