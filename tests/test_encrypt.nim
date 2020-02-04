import unittest, times

import ../src/basolato/encrypt

suite "CFB":
  test "encrypt":
    let input = $(getTime().toUnix().int()) 
    let token = encrypt(input)
    echo token
    check token.len > 0

  test "decrypt":
    let input = $(getTime().toUnix().int())
    echo input
    let hashed = encrypt(input)
    echo hashed
    let output = decrypt(hashed)
    echo output
    check input == output
