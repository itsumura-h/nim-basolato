import unittest, times, asyncdispatch

include ../src/basolato/core/security/encrypt
include ../src/basolato/core/security/token
include ../src/basolato/core/security/csrf_token
include ../src/basolato/core/security/session_db
include ../src/basolato/core/security/session
include ../src/basolato/core/security/context

# =============================================================================
#  encrypt 
# =============================================================================
block:
  let input = $(getTime().toUnix().int())
  echo input
  let hashed = encryptCtr(input)
  echo hashed
  let output = decryptCtr(hashed)
  echo output
  check input == output

block:
  let input = randStr(16)
  echo input
  let hashed = encryptCtr(input)
  echo hashed
  let output = decryptCtr(hashed)
  echo output
  check input == output

block:
  let input = randStr(24)
  echo input
  let hashed = encryptCtr(input)
  echo hashed
  let output = decryptCtr(hashed)
  echo output
  check input == output

block:
  let input = randStr(32)
  echo input
  let hashed = encryptCtr(input)
  echo hashed
  let output = decryptCtr(hashed)
  echo output
  check input == output

# =============================================================================
#  token
# =============================================================================
block:
  let token = Token.new("").token
  echo token
  check token.len > 0

block:
  let timestamp1 = getTime().toUnix()
  let timestamp2 = Token.new("").toTimestamp()
  echo timestamp1
  echo timestamp2
  check timestamp1 == timestamp2

# =============================================================================
#  csrf token
# =============================================================================
block:
  let csrf = CsrfToken.new("")
  let token = csrf.getToken()
  echo token
  check token.len > 0

block:
  let csrf = csrfToken()
  echo csrf
  check csrf.len > 0

block:
  let token = "aaaa"
  let csrf = csrfToken(token)
  echo csrf
  check csrf.len > 0

block:
  let csrf = CsrfToken.new("")
  let result = csrf.checkCsrfTimeout()
  check result == true

block:
  let csrf = CsrfToken.new("")
  let token = csrf.getToken()
  let result  = CsrfToken.new(token).checkCsrfTimeout()
  check result == true

block:
  let csrf = CsrfToken.new("")
  var token = csrf.getToken()
  echo token
  token &= "a"
  echo token
  try:
    discard CsrfToken.new(token).checkCsrfTimeout()
  except:
    let msg = getCurrentExceptionMsg()
    echo msg
    check msg == "Invalid csrf token"

# =============================================================================
#  session 
# =============================================================================
let sdb = waitFor SessionDb.new()

block:
  echo sdb.id
  check sdb.id.len > 0

block:
  waitFor sdb.set("key1", "value1")
  let result = waitFor sdb.get("key1")
  echo result
  check result == "value1"

block:
  waitFor sdb.set("key1", "value1")
  check true == waitFor sdb.some("key1")
  check false == waitFor sdb.some("key2")

block:
  waitFor sdb.set("key2", "value2")
  waitFor sdb.delete("key2")
  let result = waitFor sdb.get("key2")
  check result == ""

block:
  let sdb = waitFor SessionDb.new()
  waitFor sdb.set("key_sessionDb", "value sessionDb")
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
