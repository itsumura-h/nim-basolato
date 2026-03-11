discard """
  cmd: "nim c -d:test $file"
"""

# nim c -r -d:test ./security/test_jwt.nim

import std/unittest
import std/base64
import std/strutils
import std/json
import ../../src/basolato/core/security/jwt

proc base64UrlEncode(s: string): string =
  let encoded = base64.encode(s)
  result = encoded.replace('+', '-').replace('/', '_').replace("=", "")

suite("jwt"):
  test("decode rejects alg none"):
    let header = %*{"alg": "none", "typ": "JWT"}
    let payload = %*{"sub": "test"}
    let header64 = base64UrlEncode($header)
    let payload64 = base64UrlEncode($payload)
    let token = header64 & "." & payload64 & "."
    let (_, valid) = Jwt.decode(token, "secret")
    check valid == false

  test("decode rejects alg None"):
    let header = %*{"alg": "None", "typ": "JWT"}
    let payload = %*{"sub": "test"}
    let token = base64UrlEncode($header) & "." & base64UrlEncode($payload) & "."
    let (_, valid) = Jwt.decode(token, "secret")
    check valid == false

  test("decode rejects alg NONE"):
    let header = %*{"alg": "NONE", "typ": "JWT"}
    let payload = %*{"sub": "test"}
    let token = base64UrlEncode($header) & "." & base64UrlEncode($payload) & "."
    let (_, valid) = Jwt.decode(token, "secret")
    check valid == false

  test("encode and decode HS256"):
    let payload = $ %*{"sub": "user123"}
    let secret = "my-secret-key"
    let token = Jwt.encode(payload, secret, JwtAlgorithm.hs256)
    let (decoded, valid) = Jwt.decode(token, secret)
    check valid == true
    check decoded["sub"].getStr == "user123"

  test("decode invalid signature returns false"):
    let payload = $ %*{"sub": "user123"}
    let token = Jwt.encode(payload, "secret1", JwtAlgorithm.hs256)
    let (_, valid) = Jwt.decode(token, "secret2")
    check valid == false

  test("JwtAlgorithm type exists and hs256 is default"):
    let payload = $ %*{"x": 1}
    let t1 = Jwt.encode(payload, "k")  # default algorithm
    let t2 = Jwt.encode(payload, "k", JwtAlgorithm.hs256)
    check t1 == t2
