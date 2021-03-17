import unittest, json, tables
include ../src/basolato/core/request
include ../src/basolato/request_validation
import allographer/query_builder
import allographer/schema_builder

proc createValid(row:JsonNode):RequestValidation =
  var params = Params()
  for k, v in row:
    params[k] = Param(value:v.getStr)
  return newValidation(params)

suite "validation":
  test "accepted":
    var v = createValid(%*{"key": "on"})
    v.accepted("key")
    assert v.errors.len == 0

  test "accepted invalid":
    var v = createValid(%*{"key": "***"})
    v.accepted("key")
    assert v.errors.len > 0

  # ==========================================================================
  test "contains":
    var v = createValid(%*{"key": "111user222"})
    v.contains("key", "user")
    check v.errors.len == 0

  test "contains invalid":
    var v = createValid(%*{"key": "111user222"})
    v.contains("key", "owner")
    check v.errors.len > 0

  # ==========================================================================
  test "digits":
    var v = createValid(%*{"key": "111"})
    v.digits("key", 3)
    check v.errors.len == 0

  test "digits invalid":
    var v = createValid(%*{"key": "111"})
    v.digits("key", 2)
    check v.errors.len > 0

  # ==========================================================================
  test "email":
    let validAddresses = %*[
      "user@example.com",
      "USER@foo.COM",
      "A_US-ER@foo.bar.org",
      "first.last@foo.jp",
      "alice+bob@baz.cn"
    ]
    for row in validAddresses:
      var v = createValid(%*{"email": row})
      v.email("email")
      check v.errors.len == 0

  test "email invalid":
    let validAddresses = %*[
      "asdadad",
      "adaasda@asdaa",
      ";/@;@;:",
      "foo@bar..com",
      ""
    ]
    for row in validAddresses:
      var v = createValid(%*{"email": row})
      v.email("email")
      check v.errors.len > 0

  # ==========================================================================
  test "equals":
    var v = createValid(%*{"key": "John"})
    v.equals("key", "John")
    check v.errors.len == 0

  test "equals invalid":
    var v = createValid(%*{"key": "John"})
    v.equals("key", "Paul")
    check v.errors.len > 0

  # ==========================================================================
  test "exists":
    var params = %*{"name": "John", "age": "10"}
    var v = createValid(params)
    v.exists("name")
    check v.errors.len == 0

  test "exists invalid":
    var params = %*{"age": "10"}
    var v = createValid(params)
    v.exists("name")
    check v.errors.len > 0

  # ==========================================================================
  test "gratorThan":
    var params = %*{"age": "10"}
    var v = createValid(params)
    v.gratorThan("age", 9)
    check v.errors.len == 0

  test "gratorThan invalid":
    var params = %*{"age": "10"}
    var v = createValid(params)
    v.gratorThan("age", 11)
    check v.errors.len > 0

  # ==========================================================================
  test "inRange":
    var params = %*{"age": "10"}
    var v = createValid(params)
    v.inRange("age", min=9, max=11)
    check v.errors.len == 0

  test "inRange invalid":
    var params = %*{"age": "10"}
    var v = createValid(params)
    v.inRange("age", min=11, max=15)
    check v.errors.len > 0

  # ==========================================================================
  test "ip":
    var params = [
      "127.0.0.1",
      "192.168.0.80",
      "123.123.123.123",
      "255.255.255.255",
      "001.002.003.004",
      "2001:0db8:bd05:01d2:288a:1fc0:0001:10ee",
      "2001:db8:20:3:1000:100:20:3",
      "2001:db8::1234:0:0:9abc",
      "2001:db8::9abc",
      "::1",
      "::ffff:255.255.255.255",
    ]
    for param in params:
      var v = createValid(%*{"ip_address": param})
      v.ip("ip_address")
      check v.errors.len == 0

  test "ip invalid":
    var params = [
      "dsdsadads",
      "127.0.0.1111",
      "example.com:hoge",
      "fuga:xxxxxxx",
      "2001:0db8:bd05:01d2:288a::1fc0:0001:10ee",
      "2001:0db8:bd05:01d2:288a:1fc0:0001:10ee:11fe",
      "::",
      "1::",
      "1:2:3:4:5:6:7::",
      "::255.255.255.255",
      "2001:db8:3:4::192.0.2.33",
      "64:ff9b::192.0.2.33",
      "0.0.0.0",
      "1111.1111.1111.11111",
    ]
    for param in params:
      var v = createValid(%*{"ip_address": param})
      v.ip("ip_address")
      check v.errors.len > 0

  # ==========================================================================
  test "isBool":
    var params = %*{"key": "true"}
    var v = createValid(params)
    v.isBool("key")
    check v.errors.len == 0

    params = %*{"key": "false"}
    v = createValid(params)
    v.isBool("key")
    check v.errors.len == 0

  test "isBool invalid":
    var params = %*{"key": "111"}
    var v = createValid(params)
    v.isBool("key")
    check v.errors.len > 0

  # ==========================================================================
  test "isFloat":
    var params = %*{"key": "1.1"}
    var v = createValid(params)
    v.isFloat("key")
    check v.errors.len == 0

  test "isFloat invalid":
    var params = %*{"key": "a"}
    var v = createValid(params)
    v.isFloat("key")
    check v.errors.len > 0

  # ==========================================================================
  test "isIn":
    var params = %*{"name": "John"}
    var v = createValid(params)
    v.isIn("name", ["John", "Paul", "George", "Ringo"])
    check v.errors.len == 0

  test "isIn invalid":
    var params = %*{"name": "David"}
    var v = createValid(params)
    v.isIn("name", ["John", "Paul", "George", "Ringo"])
    check v.errors.len > 0

  # ==========================================================================
  test "isInt":
    var params = %*{"key": "1"}
    var v = createValid(params)
    v.isInt("key")
    check v.errors.len == 0

  test "isInt invalid":
    var params = %*{"key": "a"}
    var v = createValid(params)
    v.isInt("key")
    check v.errors.len > 0

  # ==========================================================================
  test "isString":
    var params = %*{"key": "aa"}
    var v = createValid(params)
    v.isString("key")
    check v.errors.len == 0

  test "isString invalid":
    var params = %*{"key": "1"}
    var v = createValid(params)
    v.isString("key")
    check v.errors.len > 0

    params = %*{"key": "1.1"}
    v = createValid(params)
    v.isString("key")
    check v.errors.len > 0

    params = %*{"key": "true"}
    v = createValid(params)
    v.isString("key")
    check v.errors.len > 0

  # ==========================================================================
  test "lessThan":
    var params = %*{"age": "25"}
    var v = createValid(params)
    v.gratorThan("age", 24)
    check v.errors.len == 0

  test "lessThan invalid":
    var params = %*{"age": "25"}
    var v = createValid(params)
    v.gratorThan("age", 26)
    check v.errors.len > 0

  # ==========================================================================
  test "numeric":
    var params = %*{"num": "36.2"}
    var v = createValid(params)
    v.numeric("num")
    check v.errors.len == 0

  test "numeric invalid":
    var params = %*{"num": "aaaaa"}
    var v = createValid(params)
    v.numeric("num")
    check v.errors.len > 0

  # ==========================================================================
  test "oneOf":
    var params = %*{"name": "John", "email": "John@gmail.com"}
    var v = createValid(params)
    v.oneOf(["name", "birth_date", "job"])
    check v.errors.len == 0

  test "oneOf invalid":
    var params = %*{"name": "John", "email": "John@gmail.com"}
    var v = createValid(params)
    v.oneOf(["birth_date", "job"])
    check v.errors.len > 0

  # ==========================================================================
  test "password":
    var params = %*{"pass": "Password1!"}
    var v = createValid(params)
    v.password("pass")
    check v.errors.len == 0

  test "password invalid":
    var params = %*{"pass": "pass12"}
    var v = createValid(params)
    v.password("pass")
    check v.errors.len > 0

  # ==========================================================================
  test "required":
    var params = %*{"name": "John", "email": "John@gmail.com"}
    var v = createValid(params)
    v.required(["name", "email"])
    check v.errors.len == 0

  test "required invalid":
    var params = %*{"name": "John", "email": "John@gmail.com"}
    var v = createValid(params)
    v.required(["name", "email", "job"])
    check v.errors.len > 0

  # ==========================================================================
  test "unique":
    schema([
      table("test_users", [
        Column().increments("id"),
        Column().string("name"),
        Column().string("email")
      ], reset=true)
    ])

    RDB().table("test_users").insert([
      %*{
        "name": "user1",
        "email": "user1@gmail.com",
      },
      %*{
        "name": "user2",
        "email": "user2@gmail.com",
      }
    ])

    var params = %*{"mail": "user3@gmail.com"}
    var v = createValid(params)
    v.unique("mail", "test_users", "email")
    check v.errors.len == 0

  test "unique invalid":
    var params = %*{"mail": "user2@gmail.com"}
    var v = createValid(params)
    v.unique("mail", "test_users", "email")
    check v.errors.len > 0
