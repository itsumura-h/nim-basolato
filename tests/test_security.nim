import unittest, times, asyncdispatch

include ../src/basolato/core/security/encrypt
include ../src/basolato/core/security/token
include ../src/basolato/core/security/csrf_token
include ../src/basolato/core/security/session_db
include ../src/basolato/core/security/session
include ../src/basolato/core/security/client

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

block:
  let token = newToken("").token
  echo token
  check token.len > 0

block:
  let timestamp1 = getTime().toUnix()
  let timestamp2 = newToken("").toTimestamp()
  echo timestamp1
  echo timestamp2
  check timestamp1 == timestamp2


block:
  let csrf = newCsrfToken("")
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
  let csrf = newCsrfToken("")
  let result = csrf.checkCsrfTimeout()
  check result == true

block:
  let csrf = newCsrfToken("")
  let token = csrf.getToken()
  let result  = token.newCsrfToken().checkCsrfTimeout()
  check result == true

block:
  let csrf = newCsrfToken("")
  var token = csrf.getToken()
  echo token
  token &= "a"
  echo token
  try:
    discard token.newCsrfToken().checkCsrfTimeout()
  except:
    let msg = getCurrentExceptionMsg()
    echo msg
    check msg == "Invalid csrf token"



let sdb = waitFor newSessionDb()

block:
  echo sdb.token
  check sdb.token.len > 0

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
  let sdb = waitFor newSessionDb()
  waitFor sdb.set("key_sessionDb", "value sessionDb")
  waitFor sdb.destroy()
  var result = ""
  try:
    result = waitFor sdb.get("key_sessionDb")
  except:
    check result == ""


block:
  let session = waitFor newSession()
  echo waitFor session.getToken()
  check waitFor(session.getToken).len > 0

block:
  let token = waitFor sdb.getToken()
  echo token
  try:
    let session = waitFor newSession(token)
    waitFor session.set("key_session", "value_session")
    check true
  except:
    check false

block:
  let token = waitFor sdb.getToken()
  echo token
  let session = waitFor newSession(token)
  check waitFor(session.some("key_session")) == true
  check waitFor(session.some("false")) == false

block:
  let token = waitFor sdb.getToken()
  echo token
  let session = waitFor newSession(token)
  let result = waitFor session.get("key_session")
  echo result
  check result == "value_session"

block:
  let token = waitFor sdb.getToken()
  echo token
  let session = waitFor newSession(token)
  waitFor session.delete("key_session")
  check waitFor(session.get("key_session")) == ""

block:
  let token = waitFor sdb.getToken()
  echo token
  var session = waitFor newSession(token)
  waitFor session.set("key_session2", "value_session2")
  waitFor session.destroy()
  var result = ""
  try:
    result = waitFor session.get("key_session2")
  except:
    check result == ""
