discard """
  cmd: "nim c --putenv:SESSION_DB_PATH=redis:6379 $options $file"
"""

# nim c -r --putenv:SESSION_DB_PATH=redis:6379 tests/auth/test_redis_session_db.nim

import std/unittest
import std/asyncdispatch
import std/json
import ../../src/basolato/core/security/session_db/redis_session_db

suite("redis session db"):
  var token:string

  test("new"):
    let session = RedisSessionDb.new("").waitFor().toInterface()
    token = session.getToken().waitFor()
    check token.len > 0

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

  test("updateNonce"):
    let session = RedisSessionDb.new(token).waitFor().toInterface()
    let nonce = session.getStr("nonce").waitFor()
    session.updateNonce().waitFor()
    check session.getStr("nonce").waitFor() != nonce

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