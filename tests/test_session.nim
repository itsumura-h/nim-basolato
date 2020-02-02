# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import ../src/basolato/session

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
    sessionDb.destroy()
    var result = ""
    try:
      result = sessionDb.get("key1")
    except:
      check result == ""

suite "Session":
  test "newSession":
    let session = newSession()
    echo session.db.token
    check session.db.token.len > 0

  test "newSession token":
    let token = sessionDb.token
    echo token
    let session = newSession(token=token)
    check session.db.token == token