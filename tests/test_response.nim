discard """
  cmd: "nim c -r --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./tests/server/session.db $file"
"""

# nim c -r --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./tests/server/session.db tests/test_response.nim

import std/asyncdispatch
import std/httpclient
import std/strformat
import std/strutils
import std/json
import std/unittest
import std/options
import ../src/basolato/settings
import ../src/basolato/core/security/session as a
import ../src/basolato/core/security/session_db as b


const HOST = "http://127.0.0.1:8000"
let session = Session.new().waitFor()
let SESSION_ID = session.getToken().waitFor()

discard Settings.new()

suite("test response"):
  test("http header"):
    let client = newHttpClient(maxRedirects=0)
    let response = client.get(&"{HOST}/set-header")
    check response.headers["key1"] == HttpHeaderValues(@["value1"])
    check response.headers["key2"] == HttpHeaderValues(@["value1, value2"])

  test("cookie key value"):
    let client = newHttpClient(maxRedirects=0)
    client.headers = newHttpHeaders({
      "Cookie": &"session_id={SESSION_ID}",
    })
    let response = client.get(&"{HOST}/set-cookie")
    check response.headers["set-cookie", 1]
            .contains("key1=value1; Path=/;")
    check response.headers["set-cookie", 2]
            .contains("key2=value2; Path=/;")

  test("session db"):
    let client = newHttpClient(maxRedirects=0)
    client.headers = newHttpHeaders({
      "Cookie": &"session_id={SESSION_ID}",
    })
    discard client.get(&"{HOST}/set-auth")
    let session = Session.new(SESSION_ID).waitFor().get()
    let sessionDb = session.db()
    echo "sessionDb.getRows().waitFor(): ",$sessionDb.getRows().waitFor()
    check "value1" == sessionDb.getStr("key1").waitFor()
    check "value2" == sessionDb.getStr("key2").waitFor()

  test("logout"):
    let client = newHttpClient(maxRedirects=0)
    let response = client.get(&"{HOST}/destroy-auth")
    check response.headers.hasKey("set-cookie")
