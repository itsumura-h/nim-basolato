import unittest, times, asyncdispatch

include ../src/basolato/core/security

suite "CTR encrypt":
  test "timestamp":
    let input = $(getTime().toUnix().int())
    echo input
    let hashed = encryptCtr(input)
    echo hashed
    let output = decryptCtr(hashed)
    echo output
    check input == output

  test "16bit":
    let input = randStr(16)
    echo input
    let hashed = encryptCtr(input)
    echo hashed
    let output = decryptCtr(hashed)
    echo output
    check input == output

  test "24bit":
    let input = randStr(24)
    echo input
    let hashed = encryptCtr(input)
    echo hashed
    let output = decryptCtr(hashed)
    echo output
    check input == output

  test "32bit":
    let input = randStr(32)
    echo input
    let hashed = encryptCtr(input)
    echo hashed
    let output = decryptCtr(hashed)
    echo output
    check input == output

suite "token":
  test "newToken":
    let token = newToken("").token
    echo token
    check token.len > 0

  test "toTimestamp":
    let timestamp1 = getTime().toUnix()
    let timestamp2 = newToken("").toTimestamp()
    echo timestamp1
    echo timestamp2
    check timestamp1 == timestamp2


suite "csrf token":
  test "newCsrfToken":
    let csrf = newCsrfToken("")
    let token = csrf.getToken()
    echo token
    check token.len > 0

  test "new csrfToken":
    let csrf = csrfToken()
    echo csrf
    check csrf.len > 0

  test "resieve csrfToken":
    let token = "aaaa"
    let csrf = csrfToken(token)
    echo csrf
    check csrf.len > 0

  test "check timeout true":
    let csrf = newCsrfToken("")
    let result = csrf.checkCsrfTimeout()
    check result == true

  test "check timeout recieve true":
    let csrf = newCsrfToken("")
    let token = csrf.getToken()
    let result  = token.newCsrfToken().checkCsrfTimeout()
    check result == true

  test "check timeout recieve false":
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



let sessionDb = waitFor newSessionDb()

suite "SessionDb":
  test "newSessionDb":
    echo sessionDb.token
    check sessionDb.token.len > 0
 
  test "set get":
    waitFor sessionDb.set("key1", "value1")
    let result = waitFor sessionDb.get("key1")
    echo result
    check result == "value1"

  test "some":
    waitFor sessionDb.set("key1", "value1")
    check true == waitFor sessionDb.some("key1")
    check false == waitFor sessionDb.some("key2")

  test "delete":
    waitFor sessionDb.set("key2", "value2")
    waitFor sessionDb.delete("key2")
    let result = waitFor sessionDb.get("key2")
    check result == ""

  test "destroy":
    let sessionDb = waitFor newSessionDb()
    waitFor sessionDb.set("key_sessionDb", "value sessionDb")
    waitFor sessionDb.destroy()
    var result = ""
    try:
      result = waitFor sessionDb.get("key_sessionDb")
    except:
      check result == ""


suite "Session":
  test "newSession":
    let session = waitFor newSession()
    echo waitFor session.getToken()
    check waitFor(session.getToken).len > 0

  test "set":
    let token = waitFor sessionDb.getToken()
    echo token
    try:
      let session = waitFor newSession(token)
      waitFor session.set("key_session", "value_session")
      check true
    except:
      check false

  test "some":
    let token = waitFor sessionDb.getToken()
    let session = waitFor newSession(token)
    check waitFor(session.some("key_session")) == true
    check waitFor(session.some("false")) == false

  test "get":
    let token = waitFor sessionDb.getToken()
    echo token
    let session = waitFor newSession(token)
    let result = waitFor session.get("key_session")
    echo result
    check result == "value_session"

  test "delete":
    let token = waitFor sessionDb.getToken()
    let session = waitFor newSession(token)
    waitFor session.delete("key_session")
    check waitFor(session.get("key_session")) == ""

  test "destroy":
    let token = waitFor sessionDb.getToken()
    var session = waitFor newSession(token)
    waitFor session.set("key_session2", "value_session2")
    waitFor session.destroy()
    var result = ""
    try:
      result = waitFor session.get("key_session2")
    except:
      check result == ""
