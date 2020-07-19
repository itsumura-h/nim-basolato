import unittest, times

include ../src/basolato/security

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



let sessionDb = newSessionDb()

suite "SessionDb":
  test "newSessionDb":
    echo sessionDb.token
    check sessionDb.token.len > 0
 
  test "set get":
    let result = sessionDb
                  .set("key1", "value1")
                  .get("key1")
    echo result
    check result == "value1"

  test "some":
    let result = sessionDb
                  .set("key1", "value1")
    check result.some("key1") == true
    check result.some("key2") == false

  test "delete":
    let result = sessionDb
                  .set("key2", "value2")
                  .delete("key2")
                  .get("key2")
    check result == ""

  test "destroy":
    let sessionDb = newSessionDb()
      .set("key_sessionDb", "value sessionDb")
    sessionDb.destroy()
    var result = ""
    try:
      result = sessionDb.get("key_sessionDb")
    except:
      check result == ""


suite "Session":
  test "newSession":
    let session = newSession()
    echo session.getToken()
    check session.getToken.len > 0

  test "set":
    let token = sessionDb.getToken()
    echo token
    try:
      newSession(token).set("key_session", "value_session")
      check true
    except:
      check false

  test "some":
    let token = sessionDb.getToken()
    check newSession(token).some("key_session") == true
    check newSession(token).some("false") == false

  test "get":
    let token = sessionDb.getToken()
    echo token
    let result = newSession(token).get("key_session")
    echo result
    check result == "value_session"

  test "delete":
    let token = sessionDb.getToken()
    let session = newSession(token)
    session.delete("key_session")
    check session.get("key_session") == ""

  test "destroy":
    let token = sessionDb.getToken()
    var session = newSession(token)
    session.set("key_session2", "value_session2")
    session.destroy()
    var result = ""
    try:
      result = session.get("key_session2")
    except:
      check result == ""
