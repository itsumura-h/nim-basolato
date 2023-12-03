discard """
  cmd: "nim c $file"
  matrix: "--putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./session.db; --putenv:SESSION_TYPE=redis --putenv:SESSION_DB_PATH=redis:6379"
"""

# nim c -r --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./session.db tests/auth/test_session.nim
# nim c -r --putenv:SESSION_TYPE=redis --putenv:SESSION_DB_PATH=redis:6379 tests/auth/test_session.nim

import std/unittest
import std/asyncdispatch
import std/asynchttpserver
import std/httpcore
import std/json
import ../../src/basolato/core/header
import ../../src/basolato/core/security/session

suite("session"):
  test("new with empty headeer"):
    let headers = newHttpHeaders()
    let request = Request(headers:headers)
    let session = Session.new(request).waitFor()
    echo session.getToken().waitFor()

  # test("new with wrong cookie"):
  #   let cookie = 
