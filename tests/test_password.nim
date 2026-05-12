discard """
  cmd: "nim c -d:test $file"
"""

# nim c -r -d:test ./test_password.nim

import std/unittest
import std/strutils

import ../src/basolato/password
import rustcrypto/algorithm/bcrypt


suite("password"):
  test("hash and verify"):
    let hash1 = genHashedPassword("Password!")
    let hash2 = genHashedPassword("Password!")

    check hash1.startsWith("$2b$")
    check hash2.startsWith("$2b$")
    check hash1 != hash2
    check Bcrypt.validateHash(hash1)
    check Bcrypt.validateHash(hash2)
    check Bcrypt.cost(hash1) == 12
    check Bcrypt.cost(hash2) == 12
    check Bcrypt.verifyPassword("Password!", hash1)
    check Bcrypt.verifyPassword("Password!", hash2)
    check isMatchPassword("Password!", hash1)
    check isMatchPassword("Password!", hash2)
    check not isMatchPassword("WrongPassword", hash1)
    check Bcrypt.needsRehash(hash1, 13)
    check not Bcrypt.needsRehash(hash1, 12)

  test("rejects invalid hashes and truncating passwords"):
    let hash = genHashedPassword("Password!")
    let lowerCostHash = hash.replace("$12$", "$10$")

    check Bcrypt.validateHash(lowerCostHash)
    check Bcrypt.cost(lowerCostHash) == 10
    check Bcrypt.needsRehash(lowerCostHash, 12)
    check not isMatchPassword("Password!", "not-a-bcrypt-hash")

    expect ValueError:
      discard genHashedPassword(repeat("x", 72))
