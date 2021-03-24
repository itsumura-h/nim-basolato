import unittest, strformat, httpclient, strutils, asyncdispatch
include ../src/basolato/core/security

const HOST = "http://0.0.0.0:5000"
let session = waitFor newSession()
let SESSION_ID = waitFor session.getToken()

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
  check response.headers["set-cookie", 0]
          .contains("key1=value1; Path=/;")
  check response.headers["set-cookie", 0]
          .contains("key2=value2; Path=/;")

block:
  let client = newHttpClient(maxRedirects=0)
  client.headers = newHttpHeaders({
    "Cookie": &"session_id={SESSION_ID}",
  })
  discard client.get(&"{HOST}/set-auth")
  let sessionDb = waitFor newSessionDb(SESSION_ID)
  check "value1" == waitFor get(sessionDb, "key1")
  check "value2" == waitFor get(sessionDb, "key2")

block:
  let client = newHttpClient(maxRedirects=0)
  let response = client.get(&"{HOST}/destroy-auth")
  echo response.headers
  check response.headers.hasKey("set-cookie")