discard """
  cmd: "nim c -d:test --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./server/session.db $file"
"""

# nim c -r -d:test --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./server/session.db test_middleware.nim

import std/unittest
import std/asyncdispatch
import std/htmlparser
import std/httpclient
import std/json
import std/strformat
import std/strutils
import std/xmltree
import ../src/basolato/middleware
import ../src/basolato/settings
import ../src/basolato/core/security/jwt
include ../src/basolato/core/security/session
include ../src/basolato/core/security/csrf_token


const HOST = "http://localhost:8000"

let client = newHttpClient(maxRedirects=0)
var jwtToken:string
var tokenInJwt:string

proc loadCsrfToken():string =
  # create session
  let response = client.get(&"{HOST}/csrf/test_routing")
  check response.code == Http200
  jwtToken = response.headers["Set-Cookie"].split(";")[0].split("=")[1]
  let (decoded, _) = Jwt.decode(jwtToken, SECRET_KEY)
  tokenInJwt = decoded["csrf_token"].getStr()

  let html = response.body().parseHtml()
  var s = newSeq[XmlNode]()
  html.findAll("input", s)
  let csrftoken = s[0].attr("value")
  return csrftoken


suite("test middleware"):
  test("csrf token valid"):
    let csrfToken = loadCsrfToken()
    client.headers = newHttpHeaders({
      "Cookie": &"session={jwtToken}",
      "Content-Type": "application/x-www-form-urlencoded",
    })
    let params = &"csrf_token={csrfToken}"
    let response = client.post(&"{HOST}/csrf/test_routing", body = params)
    check response.code == Http200


  test("csrf token invalid"):
    discard loadCsrfToken()
    client.headers = newHttpHeaders({
      "Cookie": &"session={jwtToken}",
      "Content-Type": "application/x-www-form-urlencoded",
    })
    let params = "csrf_token=invalid_token"
    let response = client.post(&"{HOST}/csrf/test_routing", body = params)
    check response.code == Http403


  test("session id invalid"):
    let invalidSessionId = "invalid_session_id"
    client.headers = newHttpHeaders({
      "Cookie": &"session={invalidSessionId}",
      "Content-Type": "application/x-www-form-urlencoded"
    })
    let csrfToken = loadCsrfToken()
    let params = &"csrf_token={csrfToken}"
    let response = client.post(&"{HOST}/session/test_routing", body = params)
    check response.code == Http403


  test("invalid params -> success"):
    let csrfToken = loadCsrfToken()
    client.headers = newHttpHeaders({
      "Cookie": &"session={jwtToken}",
      "Content-Type": "application/x-www-form-urlencoded",
    })
    var params = &"csrf_token={csrfToken}&status=invalid"
    var response = client.post(&"{HOST}/csrf/test_routing", body = params)
    check response.code == Http200
    check response.body() == "invalid status"

    params = &"csrf_token={csrfToken}&status=valid"
    response = client.post(&"{HOST}/csrf/test_routing", body = params)
    check response.code == Http200
    check response.body() == "post"
