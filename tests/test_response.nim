import unittest, strformat, httpclient, strutils, asyncdispatch
import ../src/basolato/core/security/session as a
import ../src/basolato/core/security/session_db as b

const HOST = "http://0.0.0.0:5000"
let session = waitFor genNewSession()
let SESSION_ID = waitFor session.db.getToken()

block:
  let client = newHttpClient(maxRedirects=0)
  let response = client.get(&"{HOST}/set-header")
  echo response.headers
  check response.headers["key1"] == HttpHeaderValues(@["value1"])
  check response.headers["key2"] == HttpHeaderValues(@["value1, value2"])

block:
  let client = newHttpClient(maxRedirects=0)
  client.headers = newHttpHeaders({
    "Cookie": &"session_id={SESSION_ID}",
  })
  let response = client.get(&"{HOST}/set-cookie")
  echo response.headers
  check response.headers["set-cookie", 0]
          .contains("key1=value1; Path=/;")
  check response.headers["set-cookie", 1]
          .contains("key2=value2; Path=/;")

block:
  let client = newHttpClient(maxRedirects=0)
  client.headers = newHttpHeaders({
    "Cookie": &"session_id={SESSION_ID}",
  })
  discard client.get(&"{HOST}/set-auth")
  let sessionDb = waitFor SessionDb.new(SESSION_ID)
  check "value1" == waitFor sessionDb.get("key1")
  check "value2" == waitFor sessionDb.get("key2")

block:
  let client = newHttpClient(maxRedirects=0)
  let response = client.get(&"{HOST}/destroy-auth")
  echo response.headers
  check response.headers.hasKey("set-cookie")