discard """
  cmd: "nim c -r $file"
"""

import unittest, times, asyncdispatch

include ../src/basolato/core/security/csrf_token
include ../src/basolato/core/security/session_db/file_session_db
include ../src/basolato/core/security/session_db
include ../src/basolato/core/security/session
include ../src/basolato/core/security/context


# =============================================================================
#  session 
# =============================================================================
let sdb = waitFor SessionDb.new()

block:
  waitFor sdb.setStr("key1", "value1")
  let result = waitFor sdb.get("key1")
  echo result
  check result == "value1"

block:
  waitFor sdb.setStr("key1", "value1")
  check true == waitFor sdb.some("key1")
  check false == waitFor sdb.some("key2")

block:
  waitFor sdb.setStr("key2", "value2")
  waitFor sdb.delete("key2")
  let result = waitFor sdb.get("key2")
  check result == ""

block:
  let sdb = waitFor SessionDb.new()
  waitFor sdb.setStr("key_sessionDb", "value sessionDb")
  waitFor sdb.destroy()
  var result = ""
  try:
    result = waitFor sdb.get("key_sessionDb")
  except:
    check result == ""

block:
  let session = waitFor genNewSession()
  echo waitFor session.some.getToken()
  check waitFor(session.some.getToken()).len > 0

block:
  let token = waitFor sdb.getToken()
  echo token
  try:
    let session = waitFor genNewSession(token)
    waitFor session.some.set("key_session", "value_session")
    check true
  except:
    check false

block:
  let token = waitFor sdb.getToken()
  echo token
  let session = waitFor genNewSession(token)
  check waitFor(session.some.isSome("key_session")) == true
  check waitFor(session.some.isSome("false")) == false

block:
  let token = waitFor sdb.getToken()
  echo token
  let session = waitFor genNewSession(token)
  let result = waitFor session.some.get("key_session")
  echo result
  check result == "value_session"

block:
  let token = waitFor sdb.getToken()
  echo token
  let session = waitFor genNewSession(token)
  waitFor session.some.delete("key_session")
  check waitFor(session.some.get("key_session")) == ""

block:
  let token = waitFor sdb.getToken()
  echo token
  var session = waitFor genNewSession(token)
  waitFor session.some.set("key_session2", "value_session2")
  waitFor session.some.destroy()
  var result = ""
  try:
    result = waitFor session.some.get("key_session2")
  except:
    check result == ""


# =============================================================================
#  csrf token
# =============================================================================
let csrfTokenStr = waitFor sdb.getToken()

block:
  let csrf = CsrfToken.new(csrfTokenStr)
  let token = csrf.getToken()
  echo token
  check token.len > 0

block:
  let sdb = SessionDb.new().waitFor
  sdb.updateNonce().waitFor
  let csrf = csrfToken()
  echo csrf
  check csrf.len > 0
