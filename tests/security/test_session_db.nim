discard """
  cmd: "nim c -d:test $file"
  matrix: "--putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./session.db; --putenv:SESSION_TYPE=redis --putenv:SESSION_DB_PATH=redis:6379"
"""

# nim c -r -d:test --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./session.db ./security/test_session_db.nim
# nim c -r -d:test --putenv:SESSION_TYPE=redis --putenv:SESSION_DB_PATH=redis:6379 security/test_session_db.nim

import std/unittest
import std/asyncdispatch
import std/json
import ../../src/basolato/core/security/session_db


suite("session db"):
  var token:string

  test("new"):
    let sessionDb = SessionDb.new().waitFor()
    token = sessionDb.getToken().waitFor()
    check token.len > 0

  test("new with empty should regenerate id"):
    let sessionDb = SessionDb.new("").waitFor()
    token = sessionDb.getToken().waitFor()
    check token.len > 0

  test("new with invalid id should regenerate id"):
    let sessionDb = SessionDb.new("invalid").waitFor()
    token = sessionDb.getToken().waitFor()
    check token.len > 0

  test("setStr / get"):
    let session = SessionDb.new(token).waitFor()
    session.setStr("str", "value").waitFor()
    check session.getStr("str").waitFor() == "value"

  test("setJson / getJson"):
    let session = SessionDb.new(token).waitFor()
    session.setJson("json", %*{"key": "value"}).waitFor()
    let rows = session.getJson("json").waitFor()
    check rows == %*{"key": "value"}

  test("isSome"):
    let session = SessionDb.new(token).waitFor()
    check session.isSome("str").waitFor()
    check session.isSome("invalid").waitFor() == false

  test("delete"):
    let session = SessionDb.new(token).waitFor()
    session.delete("str").waitFor()
    check session.isSome("str").waitFor() == false

  test("destroy"):
    let session = SessionDb.new(token).waitFor()
    session.setStr("str", "value").waitFor()
    check session.getStr("str").waitFor() == "value"
    session.destroy().waitFor()
    check session.isSome("str").waitFor() == false
