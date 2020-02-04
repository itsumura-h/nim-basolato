import unittest, times
include ../src/basolato/csrf_token

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
