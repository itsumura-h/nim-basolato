import std/asyncdispatch
import std/asyncfile
import std/json
import std/oids
import std/os
import std/strutils
import ../../../baseEnv


type JsonFileDb* = ref object
  id: string
  row:JsonNode

proc new*(_:type JsonFileDb):Future[JsonFileDb] {.async.}=
  let id = genOid()
  let newRow = %*{"_id": $id}
  if not fileExists(SESSION_DB_PATH):
    # create file if not exists
    var file = openAsync(SESSION_DB_PATH, fmWrite)
    file.write($newRow & "\n").await
    file.close()
  else:
    var file = openAsync(SESSION_DB_PATH, fmAppend)
    file.write($newRow & "\n").await
    file.close()
  return JsonFileDb(id: $id, row: newRow)


proc new*(_:type JsonFileDb, id:string):Future[JsonFileDb] {.async.}=
  var file:AsyncFile
  if not fileExists(SESSION_DB_PATH):
    let newId = genOid()
    let newRow = %*{"_id": $newId}
    file = openAsync(SESSION_DB_PATH, fmWrite)
    file.write($newRow & "\n").await
    file.close()
    return JsonFileDb(id: $newId, row: newRow)
  else:
    file = openAsync(SESSION_DB_PATH, fmRead)
    var content = file.readAll().await.splitLines()
    for i, row in content:
      let jsonRow = row.parseJson()
      if jsonRow["_id"].getStr() == id:
        return JsonFileDb(id:id, row:jsonRow)
    # not match
    let id = genOid()
    let newRow = %*{"_id": id}
    file = openAsync(SESSION_DB_PATH, fmWrite)
    file.write($newRow & "\n").await
    file.close()
    return JsonFileDb(id: $id, row: newRow)


proc search*(_:type JsonFileDb, key, value:string):Future[JsonFileDb] {.async.} =
  var file:AsyncFile
  if not fileExists(SESSION_DB_PATH):
    let newId = genOid()
    let newRow = %*{"_id": $newId, key: value}
    file = openAsync(SESSION_DB_PATH, fmWrite)
    file.write($newRow & "\n").await
    file.close()
    return JsonFileDb(id: $newId, row: newRow)
  else:
    file = openAsync(SESSION_DB_PATH, fmRead)
    var content = file.readAll().await.splitLines()
    for i, row in content[0..^2]:
      let jsonRow = content[i].parseJson()
      if jsonRow.hasKey(key) and jsonRow[key].getStr() == value:
        let id = jsonRow["_id"].getStr()
        return JsonFileDb(id:id, row:jsonRow)
    # not match
    let id = genOid()
    let newRow = %*{"_id": $id}
    file = openAsync(SESSION_DB_PATH, fmAppend)
    file.write($newRow & "\n").await
    file.close()
    return JsonFileDb(id: $id, row: newRow)


proc checkSessionIdValid*(_:type JsonFileDb, key, value:string):Future[bool] {.async.} =
  if not fileExists(SESSION_DB_PATH):
    return false
  
  let file = openAsync(SESSION_DB_PATH, fmRead)
  var content = file.readAll().await.splitLines()
  file.close()
  for i, row in content[0..^2]:
    let jsonRow = content[i].parseJson()
    if jsonRow.hasKey(key) and jsonRow[key].getStr() == value:
      return true
  return false


proc id*(self:JsonFileDb):string =
  return self.id


proc hasKey*(self:JsonFileDb, key:string):bool =
  return self.row.hasKey(key)


proc get*(self:JsonFileDb, key:string):JsonNode =
  return self.row[key]


proc getRow*(self:JsonFileDb):JsonNode =
  return self.row


proc set*(self:JsonFileDb, key:string, value:JsonNode) =
  self.row[key] = value


proc delete*(self:JsonFileDb, key:string) =
  if self.row.hasKey(key):
    self.row.delete(key)


proc destroy*(self:JsonFileDb) {.async.} =
  self.row = newJObject()
  var file = openAsync(SESSION_DB_PATH, fmRead)
  var content = file.readAll().await.splitLines()
  var position = 0
  for i, row in content:
    let jsonRow = row.parseJson()
    if jsonRow["_id"].getStr() == self.id:
      position = i
      break
  content.delete(position)
  file = openAsync(SESSION_DB_PATH, fmWrite)
  file.write(content.join("\n")).await
  file.close()


proc sync*(self:JsonFileDb) {.async.} =
  var file = openAsync(SESSION_DB_PATH, fmRead)
  var content = file.readAll().await.splitLines()
  var position = 0
  for i, row in content:
    let jsonRow = row.parseJson()
    if jsonRow["_id"].getStr() == self.id:
      position = i
      break
  content[position] = $self.row
  file = openAsync(SESSION_DB_PATH, fmWrite)
  file.write(content.join("\n")).await
  file.close()
