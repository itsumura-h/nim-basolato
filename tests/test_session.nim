# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
include ../src/basolato/security

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
    echo session.db.token
    check session.db.token.len > 0

  test "set":
    let token = sessionDb.getToken()
    echo token
    discard newSession(token)
              .set("key_session", "value_session")

  test "get":
    let token = sessionDb.getToken()
    echo token
    let result = newSession(token).get("key_session")
    echo result
    check result == "value_session"

  test "delete":
    let token = sessionDb.getToken()
    let session = newSession(token)
                   .delete("key_session")
    check session.get("key_session") == ""

  test "destroy":
    let token = sessionDb.getToken()
    let session = newSession(token)
                    .set("key_session2", "value_session2")
    session.destroy()
    var result = ""
    try:
      result = session.get("key_session2")
    except:
      check result == ""