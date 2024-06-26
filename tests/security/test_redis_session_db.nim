discard """
  cmd: "nim c -d:test --putenv:SESSION_TYPE=redis --putenv:SESSION_DB_PATH=redis:6379 $file"
"""

# nim c -r -d:test --putenv:SESSION_TYPE=redis --putenv:SESSION_DB_PATH=redis:6379 ./security/test_redis_session_db.nim

import std/unittest
import std/asyncdispatch
import std/json
import ../../src/basolato/core/security/session_db/redis_session_db

var token:string

suite("redis session db"):
  test("new"):
    let session = RedisSessionDb.new().waitFor().toInterface()
    token = session.getToken().waitFor()
    check token.len == 100

  test("new with empty should regenerate id"):
    let session = RedisSessionDb.new("").waitFor().toInterface()
    let newToken = session.getToken().waitFor()
    check newToken != token
    check newToken.len == 100

  test("new with invalid id should regenerate id"):
    let session = RedisSessionDb.new("invalid").waitFor().toInterface()
    let newToken = session.getToken().waitFor()
    check newToken != token
    check newToken.len == 100

  test("setStr / getStr"):
    let session = RedisSessionDb.new(token).waitFor().toInterface()
    session.setStr("str", "value").waitFor()
    check session.getStr("str").waitFor() == "value"

  test("setJson / getJson"):
    let session = RedisSessionDb.new(token).waitFor().toInterface()
    session.setJson("json", %*{"key": "value"}).waitFor()
    let rows = session.getJson("json").waitFor()
    check rows == %*{"key": "value"}

  test("isSome"):
    let session = RedisSessionDb.new(token).waitFor().toInterface()
    check session.isSome("str").waitFor()
    check session.isSome("invalid").waitFor() == false

  test("delete"):
    let session = RedisSessionDb.new(token).waitFor().toInterface()
    session.delete("str").waitFor()
    check session.isSome("str").waitFor() == false

  test("destroy"):
    var session = RedisSessionDb.new(token).waitFor().toInterface()
    session.setStr("str", "value").waitFor()
    check session.getStr("str").waitFor() == "value"
    session.destroy().waitFor()
    check session.isSome("str").waitFor() == false
    token = session.getToken().waitFor()
