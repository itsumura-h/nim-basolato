import unittest, strutils
import ../app/models/users

suite "model users":
  setup:
    var name = "Example User"
    var email = "user@example.com"

  test "should be valid":
    discard newUser(name=name, email=email)

  test "name should be present":
    try:
      discard newUser(name="", email=email)
      check false
    except:
      check true

  test "EMAIL should be present":
    try:
      discard newUser(name=name, email="   ")
      check false
    except:
      check true

  test "name should not be too long":
    try:
      name = "a".repeat(51)
      discard newUser(name=name, email=email)
      check false
    except:
      check true

  test "email should not be too long":
    try:
      email = "a".repeat(244) & "@example.com"
      discard newUser(name=name, email=email)
      check false
    except:
      check true

  test "email validation should accept valid addresses":
    let valid_addresses = @[
      "user@example.com",
      "USER@foo.COM",
      "A_US-ER@foo.bar.org",
      "first.last@foo.jp",
      "alice+bob@baz.cn"
    ]
    for email in valid_addresses:
      discard newUser(name=name, email=email)

  test "email validation should not accept invalid addresses":
    let invalid_addresses = @[
      "foo@bar..com",
    ]
    for email in invalid_addresses:
      try:
        discard newUser(name=name, email=email)
        check false:
      except:
        check true