import unittest, times

import ../src/basolato/security

suite "CTR":
  test "timestamp":
    let input = $(getTime().toUnix().int())
    echo input
    let hashed = encryptCtr(input)
    echo hashed
    let output = decryptCtr(hashed)
    echo output
    check input == output

  test "16bit":
    let input = randStr([16])
    echo input
    let hashed = encryptCtr(input)
    echo hashed
    let output = decryptCtr(hashed)
    echo output
    check input == output

  test "24bit":
    let input = randStr([24])
    echo input
    let hashed = encryptCtr(input)
    echo hashed
    let output = decryptCtr(hashed)
    echo output
    check input == output

  test "32bit":
    let input = randStr([32])
    echo input
    let hashed = encryptCtr(input)
    echo hashed
    let output = decryptCtr(hashed)
    echo output
    check input == output