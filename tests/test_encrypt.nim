import unittest

import ../src/basolato/encript

suite "login":
  test "encrypt":
    var token = "5e36c9483fc935047d8faaf9"
    token = sessionIdEncrypt(token)
    echo token
    check token.len > 0

  test "decript":
    var token = "5e36c9483fc935047d8faaf9"
    token = sessionIdEncrypt(token)
    token = sessionIdDecript(token)
    check token.len > 0