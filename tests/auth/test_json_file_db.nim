discard """
  cmd: "nim c -r $file"
"""

import std/unittest
import std/asyncdispatch
import std/json
import std/os
import std/strutils
import ../../src/basolato/core/baseEnv
import ../../src/basolato/core/security/session_db/libs/json_file_db
import ../../src/basolato/core/security/random_string


suite("json session db"):
  test("new"):
    # clear file
    removeFile(SESSION_DB_PATH)
    check fileExists(SESSION_DB_PATH) == false

    var session = JsonFileDb.new().waitFor()
    check fileExists(SESSION_DB_PATH)
    var content = readFile(SESSION_DB_PATH)
    check content.splitLines().len() == 2

    session = JsonFileDb.new().waitFor()
    content = readFile(SESSION_DB_PATH)
    check content.splitLines().len() == 3


  test("new with empty string"):
    # clear file
    removeFile(SESSION_DB_PATH)
    check fileExists(SESSION_DB_PATH) == false

    var session = JsonFileDb.new("").waitFor()
    var content = readFile(SESSION_DB_PATH)
    check content.splitLines().len() == 2

    let id = session.id
    session = JsonFileDb.new(session.id).waitFor()
    content = readFile(SESSION_DB_PATH)
    check content.splitLines().len() == 2
    check session.id == id


  test("get, set, sync"):
    var session = JsonFileDb.new().waitFor()
    session.set("key1", %"value1")
    check session.get("key1") == %"value1"
    session.set("key2", %"value2")
    check session.get("key2") == %"value2"
    session.sync().waitFor()

    let content = readFile(SESSION_DB_PATH).splitLines()
    for row in content:
      let jsonRow = parseJson(row)
      if jsonRow["_id"].getStr() == id(session):
        check jsonRow["key1"].getStr() == "value1"
        check jsonRow["key2"].getStr() == "value2"
        break


  test("hasKey"):
    let session = JsonFileDb.new().waitFor()
    session.set("key", %"value")
    check session.hasKey("key") == true
    check session.hasKey("not_exists") == false


  test("getRow"):
    let session = JsonFileDb.new().waitFor()
    session.set("key", %"value")

    let id = session.id()
    let row = session.getRow()
    check row == %*{"_id": id, "key": "value"}


  test("delete"):
    var session = JsonFileDb.new().waitFor()
    session.set("key", %"value")
    check session.get("key") == %"value"

    session.delete("key")
    expect(KeyError):
      discard session.get("key")


  test("destroy"):
    var session = JsonFileDb.new().waitFor()
    let id = session.id()
    session.set("key", %"value")
    check session.get("key") == %"value"
    session.sync().waitFor()

    session = JsonFileDb.new().waitFor()
    session.set("key", %"value")
    check session.get("key") == %"value"
    session.sync().waitFor()

    session = JsonFileDb.new(id).waitFor()
    session.destroy().waitFor()

    let content = readFile(SESSION_DB_PATH).splitLines()
    for row in content[0..^2]:
      let jsonRow = parseJson(row)
      if jsonRow["_id"].getStr() == id:
        check false
    check true


  test("search file not exists"):
    # clear file
    removeFile(SESSION_DB_PATH)
    check fileExists(SESSION_DB_PATH) == false

    let sessionId = randStr(10)
    let session = JsonFileDb.search("session_id", sessionId).waitFor()
    check session.get("session_id") == %sessionId


  test("search session id is not match"):
    let sessionId = randStr(10)
    let session = JsonFileDb.search("session_id", sessionId).waitFor()
    check session.hasKey("session_id") == false
    check session.get("_id").getStr().len() > 0


  test("search session id is match"):
    var session = JsonFileDb.new().waitFor()
    let sessionId = randStr(10)
    session.set("session_id", %sessionId)
    check session.get("session_id") == %sessionId
    session.sync().waitFor()

    session = JsonFileDb.search("session_id", sessionId).waitFor()
    check session.get("session_id") == %sessionId
