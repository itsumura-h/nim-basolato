import std/asyncdispatch
import std/strutils
import allographer/query_builder
import faker
import ../../schema

let fake = newFaker()

type Tag = object
  id: TagTable.id
  name: TagTable.name


proc tag*(rdb:PostgresConnections) {.async.} =
  var tagStrList:seq[string]
  for i in 1..30:
    while true:
      let tagName = fake.word()

      if tagStrList.contains(tagName):
        continue

      tagStrList.add(tagName)
      break

  var tags:seq[Tag]
  for tagStr in tagStrList:
    let tag = Tag(
      id: tagStr.toLowerAscii(),
      name: tagStr
    )
    tags.add(tag)
  
  rdb.table("tag").insert(tags).await
