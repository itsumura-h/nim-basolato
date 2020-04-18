import unittest, strutils
import ../domain/value_objects
import ../domain/user/user_entity
import ../domain/user/user_repository_interface
import allographer/schema_builder
import allographer/query_builder

schema([
  table("users", [
    Column().increments("id"),
    Column().string("name"),
    Column().string("email").unique(),
    Column().string("password"),
    Column().timestamps()
  ], reset=true)
])

suite "user entity":
  setup:
    var name = "Example User"
    var email = "user@example.com"
    var password = "foobar"

  test "should be valid":
    let nameType = newUserName(name)
    let emailType = newEmail(email)
    let passwordType = newPassword(password)
    discard newUser(name=nameType, email=emailType, password=passwordType)

  test "name should be present":
    try:
      let nameType = newUserName("    ")
      let emailType = newEmail(email)
      let passwordType = newPassword(password)
      discard newUser(name=nameType, email=emailType, password=passwordType)
      check false
    except:
      check true

  test "EMAIL should be present":
    try:
      let nameType = newUserName(name)
      let emailType = newEmail("   ")
      let passwordType = newPassword(password)
      discard newUser(name=nameType, email=emailType, password=passwordType)
      check false
    except:
      check true

  test "name should not be too long":
    try:
      name = "a".repeat(51)
      let nameType = newUserName(name)
      let emailType = newEmail(email)
      let passwordType = newPassword(password)
      discard newUser(name=nameType, email=emailType, password=passwordType)
      check false
    except:
      check true

  test "email should not be too long":
    try:
      email = "a".repeat(244) & "@example.com"
      let nameType = newUserName(name)
      let emailType = newEmail(email)
      let passwordType = newPassword(password)
      discard newUser(name=nameType, email=emailType, password=passwordType)
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
      let nameType = newUserName(name)
      let emailType = newEmail(email)
      let passwordType = newPassword(password)
      discard newUser(name=nameType, email=emailType, password=passwordType)

  test "email validation should not accept invalid addresses":
    let invalid_addresses = @[
      "foo@bar..com",
    ]
    for email in invalid_addresses:
      try:
        let nameType = newUserName(name)
        let emailType = newEmail(email)
        let passwordType = newPassword(password)
        discard newUser(name=nameType, email=emailType, password=passwordType)
        check false:
      except:
        check true

  test "email addresses should be unique":
    let nameType = newUserName(name)
    let emailType = newEmail(email)
    let passwordType = newPassword(password)
    let user = newUser(name=nameType, email=emailType, password=passwordType)
    let duplicate_user = user.deepCopy()
    newIUserRepository().store(duplicate_user)
    try:
      let nameType = newUserName(name)
      let emailType = newEmail(email)
      let passwordType = newPassword(password)
      discard newUser(name=nameType, email=emailType, password=passwordType)
      check false
    except:
      check true

  test "email addresses should be saved as lower-case":
    let mixedCaseEmail = "Foo@ExAMPle.CoM"
    let nameType = newUserName(name)
    let emailType = newEmail(mixedCaseEmail)
    let passwordType = newPassword(password)
    let tmpUser = newUser(name=nameType, email=emailType, password=passwordType)
    check mixedCaseEmail.toLowerAscii == tmpUser.getEmail()

  test "password should be present (nonblank)":
    password = " ".repeat(6)
    try:
      let nameType = newUserName(name)
      let emailType = newEmail(email)
      let passwordType = newPassword(password)
      discard newUser(name=nameType, email=emailType, password=passwordType)
      check false
    except:
      check true

  test "password should have a minimum length":
    password = "a".repeat(5)
    try:
      let nameType = newUserName(name)
      let emailType = newEmail(email)
      let passwordType = newPassword(password)
      discard newUser(name=nameType, email=emailType, password=passwordType)
      check false
    except:
      check true


RDB().table("users").where("id", ">", 0).delete()