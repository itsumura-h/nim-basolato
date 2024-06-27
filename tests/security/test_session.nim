discard """
  cmd: "nim c -d:test $file"
  matrix: "--putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./session.db; --putenv:SESSION_TYPE=redis --putenv:SESSION_DB_PATH=redis:6379"
"""

# nim c -r -d:test --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./session.db ./security/test_session.nim
# nim c -r -d:test --putenv:SESSION_TYPE=redis --putenv:SESSION_DB_PATH=redis:6379 ./security/test_session.nim

import std/unittest
import std/asyncdispatch
import std/json
import ../../src/basolato/core/security/session


suite("session db"):
  var token:string

  test("new"):
    let session = Session.new().waitFor()
    token = session.getToken().waitFor()
    check token.len == 100

  test("new with empty should regenerate id"):
    let session = Session.new("").waitFor()
    token = session.getToken().waitFor()
    check token.len == 100

  test("new with invalid id should regenerate id"):
    let session = Session.new("invalid").waitFor()
    token = session.getToken().waitFor()
    check token.len == 100

  test("set / get"):
    let session = Session.new(token).waitFor()
    session.set("str", "value").waitFor()
    check session.get("str").waitFor() == "value"

  test("isSome"):
    let session = Session.new(token).waitFor()
    check session.isSome("str").waitFor()
    check session.isSome("invalid").waitFor() == false

  test("updateCsrfToken"):
    let session = Session.new(token).waitFor()
    session.updateCsrfToken().waitFor()
    let csrfToken = globalCsrfToken
    session.updateCsrfToken().waitFor()
    check csrfToken != globalCsrfToken

  test("delete"):
    let session = Session.new(token).waitFor()
    session.delete("str").waitFor()
    check session.isSome("str").waitFor() == false

  test("destroy"):
    let session = Session.new(token).waitFor()
    session.set("str", "value").waitFor()
    check session.get("str").waitFor() == "value"
    session.destroy().waitFor()
    check session.isSome("str").waitFor() == false
