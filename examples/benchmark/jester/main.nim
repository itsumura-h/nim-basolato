import os, json, random, strutils, sequtils, cgi, algorithm
import db_postgres
import allographer/query_builder
import jester
include "fortune.tmpl"

const
  DRIVER = getEnv("DB_DRIVER","sqlite").string
  CONN = getEnv("DB_CONNECTION").string
  USER = getEnv("DB_USER").string
  PASSWORD = getEnv("DB_PASSWORD").string
  DATABASE = getEnv("DB_DATABASE").string

let db = open(CONN, USER, PASSWORD, DATABASE)

settings:
  port = Port(5000)

routes:
  get "/json":
    var data = $(%*{"message": "Hello, World!"})
    resp data, "application/json"

  get "/plaintext":
    const data = "Hello, World!"
    resp data, "text/plain"

  get "/db":
    # let i = rand(1..10000)
    # let row = db.getRow(sql"SELECT * FROM world WHERE id = ?", i)
    # let response = %*{"id": row[0].parseInt, "randomnumber": row[1].parseInt}
    # echo response
    let i = rand(range1_10000)
    let response = await rdb().table("world").asyncFind(i)
    resp response

  get "/queries":
    var countNum:int
    try:
      countNum = request.params["queries"].parseInt()
    except:
      countNum = 1

    if countNum < 1:
      countNum = 1
    elif countNum > 500:
      countNum = 500

    var response = newSeq[JsonNode](countNum)
    for i in 1..countNum:
      let index = rand(1..10000)
      let row = db.getRow(sql"SELECT * FROM world WHERE id = ? LIMIT 1;", index)
      response[i-1] = %*{"id": row[0].parseInt, "randomnumber": row[1].parseInt}
    resp %response

  get "/fortunes":
    var rows = db.getAllRows(sql"SELECT * FROM fortune ORDER BY message ASC;")
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
    resp fortuneView(newRows)

  get "/updates":

    var countNum:int
    try:
      countNum = request.params["queries"].parseInt()
    except:
      countNum = 1

    if countNum < 1:
      countNum = 1
    elif countNum > 500:
      countNum = 500

    var response = newSeq[JsonNode](countNum)
    for i in 1..countNum:
      let index = rand(1..10000)
      let newRandomNumber = rand(1..10000)
      discard db.getAllRows(sql"SELECT * FROM world")
      db.exec(sql"UPDATE world SET randomNumber = ? WHERE id = ?", $index, $newRandomNumber)
      response[i-1] =  %*{"id":index, "randomNumber": newRandomNumber}
    resp %response
