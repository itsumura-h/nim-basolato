discard """
  cmd: "nim c -d:test --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./server/session.db $file"
"""

# nim c -r -d:test --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./server/session.db test_response.nim

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
import ../src/basolato/core/security/jwt


const HOST = "http://127.0.0.1:8000"

suite("test response"):
  setup:
    var client = newHttpClient(maxRedirects=0)
    var response = client.get(&"{HOST}/csrf/test_routing")
    check response.code == Http200
    let jwtToken = response.headers["Set-Cookie"].split(";")[0].split("=")[1]
    let (decoded, _) = Jwt.decode(jwtToken, SECRET_KEY)
    let sessionId = decoded["session_id"].getStr()
    client.headers = newHttpHeaders({
      "Cookie": &"session={jwtToken}",
      "Content-Type": "application/x-www-form-urlencoded",
    })


  test("http header"):
    response = client.get(&"{HOST}/set-header")
    check response.headers["key1"] == HttpHeaderValues(@["value1"])
    check response.headers["key2"] == HttpHeaderValues(@["value1, value2"])


  test("cookie key value"):
    response = client.get(&"{HOST}/set-cookie")
    check response.headers["set-cookie", 1]
            .contains("key1=value1; Path=/;")
    check response.headers["set-cookie", 2]
            .contains("key2=value2; Path=/;")


  test("session db"):
    discard client.get(&"{HOST}/set-auth")
    let session = Session.new(sessionId).waitFor().get()
    let sessionDb = session.db()
    echo "sessionDb.getRows().waitFor(): ",$sessionDb.getRows().waitFor()
    check "value1" == sessionDb.getStr("key1").waitFor()
    check "value2" == sessionDb.getStr("key2").waitFor()


  test("logout"):
    response = client.get(&"{HOST}/destroy-auth")
    check response.headers.hasKey("set-cookie")
