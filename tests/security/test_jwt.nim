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
    let (_, valid) = Jwt.verifyAndDecode(token, "secret")
    check valid == false

  test("decode rejects alg None"):
    let header = %*{"alg": "None", "typ": "JWT"}
    let payload = %*{"sub": "test"}
    let token = base64UrlEncode($header) & "." & base64UrlEncode($payload) & "."
    let (_, valid) = Jwt.verifyAndDecode(token, "secret")
    check valid == false

  test("decode rejects alg NONE"):
    let header = %*{"alg": "NONE", "typ": "JWT"}
    let payload = %*{"sub": "test"}
    let token = base64UrlEncode($header) & "." & base64UrlEncode($payload) & "."
    let (_, valid) = Jwt.verifyAndDecode(token, "secret")
    check valid == false

  test("sign and verify HS256"):
    let payload = %*{"sub": "user123"}
    let secret = "my-secret-key"
    let secretKey = Jwt.secretKey(jwtHS256, secret)
    let token = Jwt.sign(jwtHS256, payload, secretKey)
    let valid = Jwt.verify(jwtHS256, Jwt.publicKey(secretKey), token)
    let decoded = Jwt.decode(token)
    check valid == true
    check decoded["sub"].getStr == "user123"

  test("verifyAndDecode invalid signature returns false"):
    let payload = %*{"sub": "user123"}
    let token = Jwt.sign(payload, "secret1")
    let (_, valid) = Jwt.verifyAndDecode(token, "secret2")
    check valid == false

  test("default algorithm is HS256"):
    let payload = %*{"x": 1}
    let token = Jwt.sign(payload, "k")
    let decoded = Jwt.decode(token)
    check Jwt.verify(token, "k") == true
    check decoded["x"].getInt == 1
