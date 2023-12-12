discard """
  cmd: "nim c --putenv:SESSION_DB_PATH=./session.db $options $file"
"""

# nim c -r --putenv:SESSION_DB_PATH=./session.db tests/auth/test_json_session_db.nim

import std/unittest
import std/asyncdispatch
import std/json
import ../../src/basolato/core/security/session_db/json_session_db


suite("json session db"):
  var token:string

  test("new"):
    let session = JsonSessionDb.new().waitFor().toInterface()
    token = session.getToken().waitFor()
    echo "token:",token
    check token.len == 256


  test("new with empty should regenerate id"):
    let session = JsonSessionDb.new("").waitFor().toInterface()
    token = session.getToken().waitFor()
    echo "token:",token
    check token.len == 256

  
  test("new with invalid id should regenerate id"):
    let session = JsonSessionDb.new("invalid").waitFor().toInterface()
    token = session.getToken().waitFor()
    echo "token:",token
    check token.len == 256


  test("new with token"):
    let session = JsonSessionDb.new(token).waitFor().toInterface()
    check session.getToken().waitFor() == token


  test("setStr / getStr"):
    let session = JsonSessionDb.new(token).waitFor().toInterface()
    session.setStr("str", "value").waitFor()
    check session.getStr("str").waitFor() == "value"


  test("setJson / getJson"):
    let session = JsonSessionDb.new(token).waitFor().toInterface()
    session.setJson("json", %*{"key": "value"}).waitFor()
    let rows = session.getJson("json").waitFor()
    check rows == %*{"key": "value"}


  test("isSome"):
    let session = JsonSessionDb.new(token).waitFor().toInterface()
    check session.isSome("str").waitFor()
    check session.isSome("invalid").waitFor() == false


  test("updateNonce"):
    let session = JsonSessionDb.new(token).waitFor().toInterface()
    session.updateNonce().waitFor()
    let nonce = session.getStr("nonce").waitFor()
    session.updateNonce().waitFor()
    check session.getStr("nonce").waitFor() != nonce


  test("delete"):
    let session = JsonSessionDb.new(token).waitFor().toInterface()
    session.delete("str").waitFor()
    check session.isSome("str").waitFor() == false


  test("destroy"):
    var session = JsonSessionDb.new(token).waitFor().toInterface()
    session.setStr("str", "value").waitFor()
    check session.getStr("str").waitFor() == "value"
    session.destroy().waitFor()
    check session.isSome("str").waitFor() == false
