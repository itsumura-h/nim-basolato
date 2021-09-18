import asyncdispatch, json, strutils, strformat, random, times
import allographer/query_builder
import faker
import markdown
import ../../libs/uid
from ../../config/database import rdb

let fake = newFaker()
randomize()

proc sentence(i:int):string =
  var str = ""
  for _ in 0..i:
    if str.len > 0: str.add(" ")
    str.add( fake.word() )
  return str

proc todoDate():(int, DateTime, DateTime) =
  let status = rand(1..3)
  var start = 0
  var deadline = 0
  case status
  of 1: #todo
    start = rand(0..60)
    deadline = rand(start..60)
    return (
      status,
      getTime().utc + initTimeInterval(days=start),
      getTime().utc + initTimeInterval(days=deadline),
    )
  of 2: #doing
    start = rand(0..30)
    deadline = rand(0..30)
    return (
      status,
      getTime().utc - initTimeInterval(days=start),
      getTime().utc + initTimeInterval(days=deadline),
    )
  of 3: #done
    start = rand(0..60)
    deadline = rand(0..start)
    return (
      status,
      getTime().utc - initTimeInterval(days=start),
      getTime().utc - initTimeInterval(days=deadline),
    )
  else:
    discard

proc content():(string, string) =
  let contentMd = fmt"""
## {sentence(5)}
{sentence(10)}

- {sentence(3)}
  - {sentence(3)}
  - {sentence(3)}"""
  let contentHtml = markdown(contentMd)
  return (contentMd, contentHtml)

proc todo*() {.async.} =
  seeder rdb, "todo":
    var data: seq[JsonNode]
    for i in 1..30:
      let contentVal = content()
      let todoDateVal = todoDate()
      data.add(%*{
        "id": genUid(),
        "title": sentence(5),
        "content_md": contentVal[0],
        "content_html": contentVal[1],
        "created_by": rand(2..11),
        "assign_to": rand(2..11),
        "status_id": todoDateVal[0],
        "start_on": (todoDateVal[1]).format("yyyy-MM-dd"),
        "deadline": (todoDateVal[2]).format("yyyy-MM-dd"),
      })
    await rdb.table("todo").insert(data)
