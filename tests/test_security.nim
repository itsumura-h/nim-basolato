discard """
  cmd: "nim c -r $file"
"""

import std/unittest
import std/times
import std/asyncdispatch
include ../src/basolato/core/security/csrf_token
include ../src/basolato/core/security/session_db/file_session_db
include ../src/basolato/core/security/session_db
include ../src/basolato/core/security/session
include ../src/basolato/core/security/context


# =============================================================================
#  session 
# =============================================================================
let sdb = SessionDb.new().waitFor

block:
  sdb.setStr("key1", "value1").waitFor
  let result = sdb.get("key1").waitFor
  echo result
  check result == "value1"

block:
  sdb.setStr("key1", "value1").waitFor
  check true == sdb.some("key1").waitFor
  check false == sdb.some("key2").waitFor

block:
  sdb.setStr("key2", "value2").waitFor
  sdb.delete("key2").waitFor
  let result = sdb.get("key2").waitFor
  check result == ""

block:
  let sdb = SessionDb.new().waitFor
  sdb.setStr("key_sessionDb", "value sessionDb").waitFor
  sdb.destroy().waitFor
  var result = ""
  try:
    result = sdb.get("key_sessionDb").waitFor
  except:
    check result == ""

block:
  let session = genNewSession().waitFor
  echo session.some.getToken().waitFor
  check session.some.getToken().waitFor.len > 0

block:
  let token = sdb.getToken().waitFor
  echo token
  try:
    let session = genNewSession(token).waitFor
    waitFor session.some.set("key_session", "value_session")
    check true
  except:
    check false

block:
  let token = sdb.getToken().waitFor
  echo token
  let session = genNewSession(token).waitFor
  check session.some.isSome("key_session").waitFor == true
  check session.some.isSome("false").waitFor == false

block:
  let token = sdb.getToken().waitFor
  echo token
  let session = genNewSession(token).waitFor
  let result = session.some.get("key_session").waitFor
  echo result
  check result == "value_session"

block:
  let token = waitFor sdb.getToken()
  echo token
  let session = waitFor genNewSession(token)
  waitFor session.some.delete("key_session")
  check waitFor(session.some.get("key_session")) == ""

block:
  let token = sdb.getToken().waitFor
  echo token
  var session = waitFor genNewSession(token)
  session.some.set("key_session2", "value_session2").waitFor
  session.some.destroy().waitFor
  var result = ""
  try:
    result = session.some.get("key_session2").waitFor
  except:
    check result == ""


# =============================================================================
#  csrf token
# =============================================================================
let csrfTokenStr = sdb.getToken().waitFor

block:
  let csrf = CsrfToken.new(csrfTokenStr)
  let token = csrf.getToken()
  echo token
  check token.len > 0

block:
  let sdb = SessionDb.new().waitFor
  sdb.updateNonce().waitFor
  let csrf = csrfToken()
  echo csrf.toString()
  echo csrf.getToken()
  check csrf.toString().len > 0
