import unittest, json, tables
import ../src/basolato/validation


suite "validation":
  test "accepted":
    var params = {"key": "on"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .accepted("key")
    check v.errors.len == 0

    params = {"key": "checked"}.toTable()
    v = Validation(params: params,
                    errors: newJObject())
                    .accepted("key", "checked")
    check v.errors.len == 0

  test "accepted invalid":
    var params = {"key": ""}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .accepted("key")
    check v.errors.len > 0

  # ==========================================================================
  test "contains":
    var params = {"key": "111user222"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .contains("key", "user")
    check v.errors.len == 0

  test "contains invalid":
    var params = {"key": "111user222"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .contains("key", "owner")
    check v.errors.len > 0

  # ==========================================================================
  test "email":
    let valid_addresses = [
      {"email": "user@example.com"}.toTable(),
      {"email": "USER@foo.COM"}.toTable(),
      {"email": "A_US-ER@foo.bar.org"}.toTable(),
      {"email": "first.last@foo.jp"}.toTable(),
      {"email": "alice+bob@baz.cn"}.toTable()
    ]

    for valid_address in valid_addresses:
      let v = Validation(params: valid_address,
                          errors: newJObject())
                        .email("email")
      check v.errors.len == 0

  test "email not valid":
    let valid_addresses = [
      {"email": "asdadad"}.toTable(),
      {"email": "adaasda@asdaa"}.toTable(),
      {"email": ";/@;@;:"}.toTable(),
      {"email": "foo@bar..com"}.toTable(),
      {"email": ""}.toTable()
    ]

    for valid_address in valid_addresses:
      let v = Validation(params: valid_address,
                          errors: newJObject())
                        .email("email")
      check v.errors.len > 0

  # ==========================================================================
  test "equals":
    var params = {"key": "John"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .equals("key", "John")
    check v.errors.len == 0

  test "equals invalid":
    var params = {"key": "John"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .equals("key", "Paul")
    check v.errors.len > 0

  # ==========================================================================
  test "exists":
    var params = {"name": "John", "age": "10"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .exists("name")
    check v.errors.len == 0

  test "exists invalid":
    var params = {"age": "10"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .exists("name")
    check v.errors.len > 0

  # ==========================================================================
  test "gratorThan":
    var params = {"age": "10"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .gratorThan("age", 9)
    check v.errors.len == 0

  test "gratorThan invalid":
    var params = {"age": "10"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .gratorThan("age", 11)
    check v.errors.len > 0

  # ==========================================================================
  test "inRange":
    var params = {"age": "10"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .inRange("age", min=9, max=11)
    check v.errors.len == 0

  test "inRange invalid":
    var params = {"age": "10"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .inRange("age", min=11, max=15)
    check v.errors.len > 0

  # ==========================================================================
  test "ip":
    var params = {"ip_address": "127.0.0.1"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .ip("ip_address")
    check v.errors.len == 0

  test "ip invalid":
    var params = {"ip_address": "dsdsadads"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .ip("ip_address")
    check v.errors.len > 0

  # ==========================================================================
  test "isIn":
    var params = {"name": "John"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .isIn("name", ["John", "Paul", "George", "Ringo"])
    check v.errors.len == 0

  test "isIn invalid":
    var params = {"name": "David"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .isIn("name", ["John", "Paul", "George", "Ringo"])
    check v.errors.len > 0

  # ==========================================================================
  test "lessThan":
    var params = {"age": "25"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .gratorThan("age", 24)
    check v.errors.len == 0

  test "lessThan invalid":
    var params = {"age": "25"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .gratorThan("age", 26)
    check v.errors.len > 0

  # ==========================================================================
  test "numeric":
    var params = {"num": "36.2"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .numeric("num")
    check v.errors.len == 0

  test "numeric invalid":
    var params = {"num": "aaaaa"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .numeric("num")
    check v.errors.len > 0

  # ==========================================================================
  test "oneOf":
    var params = {"name": "John", "email": "John@gmail.com"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .oneOf(["name", "birth_date", "job"])
    check v.errors.len == 0

  test "oneOf invalid":
    var params = {"name": "John", "email": "John@gmail.com"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .oneOf(["birth_date", "job"])
    check v.errors.len > 0

  # ==========================================================================
  test "password":
    var params = {"pass": "Password1!"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .password("pass")
    check v.errors.len == 0

  test "password invalid":
    var params = {"pass": "pass12"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .password("pass")
    check v.errors.len > 0

  # ==========================================================================
  test "required":
    var params = {"name": "John", "email": "John@gmail.com"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .required(["name", "email"])
    check v.errors.len == 0

  test "required invalid":
    var params = {"name": "John", "email": "John@gmail.com"}.toTable()
    var v = Validation(params: params,
                        errors: newJObject())
                        .required(["name", "email", "job"])
    check v.errors.len > 0