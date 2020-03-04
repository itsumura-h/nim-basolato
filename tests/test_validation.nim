import unittest, json, tables
import ../src/basolato/validation


suite "validation":
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
      {"email": ""}.toTable()
    ]

    for valid_address in valid_addresses:
      let v = Validation(params: valid_address,
                          errors: newJObject())
                        .email("email")
      check v.errors.len > 0