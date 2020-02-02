import unittest

import ../src/basolato/encript

suite "login":
  test "encrypt":
    var token = "5e36c9483fc935047d8faaf9"
    token = loginEncrypt(token)
    echo token
    check token.len > 0

  test "decript":
    var token = "5e36c9483fc935047d8faaf9"
    token = loginEncrypt(token)
    token = loginDecript(token)
    check token.len > 0