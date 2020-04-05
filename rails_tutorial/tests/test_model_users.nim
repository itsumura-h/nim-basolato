import unittest, strutils
import ../app/models/users
import allographer/query_builder

suite "model users":
  setup:
    var name = "Example User"
    var email = "user@example.com"
    var password = "foobar"

  test "should be valid":
    discard newUser(name=name, email=email, password=password)

  test "name should be present":
    try:
      discard newUser(name="", email=email, password=password)
      check false
    except:
      check true

  test "EMAIL should be present":
    try:
      discard newUser(name=name, email="   ", password=password)
      check false
    except:
      check true

  test "name should not be too long":
    try:
      name = "a".repeat(51)
      discard newUser(name=name, email=email, password=password)
      check false
    except:
      check true

  test "email should not be too long":
    try:
      email = "a".repeat(244) & "@example.com"
      discard newUser(name=name, email=email, password=password)
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
      discard newUser(name=name, email=email, password=password)

  test "email validation should not accept invalid addresses":
    let invalid_addresses = @[
      "foo@bar..com",
    ]
    for email in invalid_addresses:
      try:
        discard newUser(name=name, email=email, password=password)
        check false:
      except:
        check true

  test "email addresses should be unique":
    let user = newUser(name=name, email=email, password=password)
    let duplicate_user = user.deepCopy()
    duplicate_user.save()
    try:
      discard newUser(name=name, email=email, password=password)
      check false
    except:
      check true

  test "email addresses should be saved as lower-case":
    let mixedCaseEmail = "Foo@ExAMPle.CoM"
    let tmpUser = newUser(name=name, email=mixedCaseEmail, password=password)
    tmpUser.save()
    check mixedCaseEmail.toLowerAscii == tmpUser.email.get

  test "password should be present (nonblank)":
    password = " ".repeat(6)
    try:
      discard newUser(name=name, email=email, password=password)
      check false
    except:
      check true

  test "password should have a minimum length":
    password = "a".repeat(5)
    try:
      discard newUser(name=name, email=email, password=password)
      check false
    except:
      check true


RDB().table("users").where("id", ">", 0).delete()