discard """
"""

import unittest, times
include ../src/basolato/core/request
include ../src/basolato/request_validation

echo "=== accepted"
block:
  let v = newValidation()
  check v.accepted("on")
  check v.accepted("yes")
  check v.accepted("1")
  check v.accepted("true")
  check v.accepted("a") == false

block:
  let params = Params()
  params["on"] = Param(value:"on")
  params["yes"] = Param(value:"yes")
  params["one"] = Param(value:"1")
  params["true"] = Param(value:"true")
  params["invalid"] = Param(value:"invalid")
  var v = newRequestValidation(params)
  v.accepted("on")
  v.accepted("yes")
  v.accepted("one")
  v.accepted("true")
  check v.hasError == false

  v.accepted("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be accepted."


echo "=== domain"
block:
  let v = newValidation()
  check v.domain("domain.com")
  check v.domain("[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]")
  check v.domain("[2001:0db8:bd05:01d2:288a::1fc0:0001:10ee]") == false

block:
  let params = Params()
  params["a"] = Param(value:"domain.com")
  params["b"] = Param(value:"[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]")
  params["c"] = Param(value:"[2001:0db8:bd05:01d2:288a::1fc0:0001:10ee]")
  let v = newRequestValidation(params)
  v.domain("a")
  v.domain("b")
  check v.hasError == false

  v.domain("c")
  check v.hasError
  check v.errors["c"][0] == "The c must be a valid domain."


echo "=== after"
block:
  let v = newValidation()
  let a = "2020-01-02".parse("yyyy-MM-dd")
  let b = "2020-01-01".parse("yyyy-MM-dd")
  let c = "2020-01-03".parse("yyyy-MM-dd")
  check v.after(a, b)
  check v.after(a, c) == false

block:
  let params = Params()
  params["a"] = Param(value:"2020-01-02")
  params["b"] = Param(value:"2020-01-01")
  params["c"] = Param(value:"2020-01-03")
  let v = newRequestValidation(params)
  v.after("a", "b", "yyyy-MM-dd")
  v.after("a", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError == false
  v.after("a", "c", "yyyy-MM-dd")
  v.after("a", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError
  check v.errors["a"][0] == "The a must be a date after 2020-01-03."
  check v.errors["a"][1] == "The a must be a date after 2020-01-03T00:00:00+00:00."

echo "=== after_or_equal"
block:
  let v = newValidation()
  let base = "2020-01-02".parse("yyyy-MM-dd")
  let before = "2020-01-01".parse("yyyy-MM-dd")
  let after = "2020-01-03".parse("yyyy-MM-dd")
  let same = "2020-01-02".parse("yyyy-MM-dd")
  check v.afterOrEqual(base, before)
  check v.afterOrEqual(base, same)
  check v.afterOrEqual(base, after) == false

block:
  let params = Params()
  params["base"] = Param(value:"2020-01-02")
  params["before"] = Param(value:"2020-01-01")
  params["after"] = Param(value:"2020-01-03")
  params["same"] = Param(value:"2020-01-02")
  let v = newRequestValidation(params)
  v.afterOrEqual("base", "before", "yyyy-MM-dd")
  v.afterOrEqual("base", "same", "yyyy-MM-dd")
  v.afterOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError == false
  v.afterOrEqual("base", "after", "yyyy-MM-dd")
  v.afterOrEqual("base", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError
  check v.errors["base"][0] == "The base must be a date after or equal to 2020-01-03."
  check v.errors["base"][1] == "The base must be a date after or equal to 2020-01-03T00:00:00+00:00."

echo "=== alpha"
block:
  let v = newValidation()
  const small = "abcdefghijklmnopqrstuvwxyz"
  const large = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  const number = "1234567890"
  const mark = "!\"#$%&'()~=~|`{}*+<>?_@[]:;,./^-"
  const ja = "あいうえお"
  check v.alpha(small)
  check v.alpha(large)
  check v.alpha(number) == false
  check v.alpha(mark) == false
  check v.alpha(ja) == false

block:
  let params = Params()
  params["small"] = Param(value:"abcdefghijklmnopqrstuvwxyz")
  params["large"] = Param(value:"ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  params["number"] = Param(value:"1234567890")
  params["mark"] = Param(value:"!\"#$%&'()~=~|`{}*+<>?_@[]:;,./^-")
  params["ja"] = Param(value:"あいうえお")
  let v = newRequestValidation(params)
  v.alpha("small")
  v.alpha("large")
  check v.hasError == false
  v.alpha("number")
  v.alpha("mark")
  v.alpha("ja")
  check v.errors["number"][0] == "The number may only contain letters."
  check v.errors["mark"][0] == "The mark may only contain letters."
  check v.errors["ja"][0] == "The ja may only contain letters."


echo "=== alphaDash"
block:
  let v = newValidation()
  const letter = "abcAbc012"
  const withDash = "abcAbc012-_"
  const ja = "aA0あいうえお"
  check v.alphaDash(letter)
  check v.alphaDash(withDash)
  check v.alphaDash(ja) == false

block:
  let params = Params()
  params["letter"] = Param(value:"abcABC012")
  params["withDash"] = Param(value:"abcABC012-_")
  params["ja"] = Param(value:"aA0あいうえお")
  let v = newRequestValidation(params)
  v.alphaDash("letter")
  v.alphaDash("withDash")
  check v.hasError == false
  v.alphaDash("ja")
  check v.hasError
  check v.errors["ja"][0] == "The ja may only contain letters, numbers, dashes and underscores."


echo "=== alphaNum"
block:
  let v = newValidation()
  const letter = "abcABC012"
  const withDash = "abcABC012-_"
  const ja = "aA0あいうえお"
  check v.alphaNum(letter)
  check v.alphaNum(withDash) == false
  check v.alphaNum(ja) == false

block:
  let params = Params()
  params["letter"] = Param(value:"abcABC012")
  params["withDash"] = Param(value:"abcABC012-_")
  params["ja"] = Param(value:"aA0あいうえお")
  let v = newRequestValidation(params)
  v.alphaNum("letter")
  check v.hasError == false
  v.alphaNum("withDash")
  v.alphaNum("ja")
  check v.hasError
  check v.errors["withDash"][0] == "The withDash may only contain letters and numbers."
  check v.errors["ja"][0] == "The ja may only contain letters and numbers."

echo "=== array"
block:
  let v = newValidation()
  const valid = "a, b, c"
  const dict = """{"a": "a", "b": "b"}"""
  const kv = "a=a, b=b"
  const str = "adaddadad"
  const number = "1313193"
  check v.array(valid)
  check v.array(dict) == false
  check v.array(kv) == false
  check v.array(str) == false
  check v.array(number) == false

block:
  let params = Params()
  params["valid"] = Param(value:"a, b, c")
  params["dict"] = Param(value:"""{"a": "a", "b": "b"}""")
  params["kv"] = Param(value:"a=a, b=b")
  params["str"] = Param(value:"adaddadad")
  params["number"] = Param(value:"1313193")

  let v = newRequestValidation(params)
  v.array("valid")
  check v.hasError == false
  v.array("dict")
  v.array("kv")
  v.array("str")
  v.array("number")
  check v.hasError
  check v.errors["kv"][0] == "The kv must be an array."
  check v.errors["number"][0] == "The number must be an array."
  check v.errors["dict"][0] == "The dict must be an array."
  check v.errors["str"][0] == "The str must be an array."


echo "=== before"
block:
  let v = newValidation()
  let a = "2020-01-02".parse("yyyy-MM-dd")
  let b = "2020-01-01".parse("yyyy-MM-dd")
  let c = "2020-01-03".parse("yyyy-MM-dd")
  check v.before(a, c)
  check v.before(a, b) == false

block:
  let params = Params()
  params["a"] = Param(value:"2020-01-02")
  params["b"] = Param(value:"2020-01-01")
  params["c"] = Param(value:"2020-01-03")
  let v = newRequestValidation(params)
  v.before("a", "c", "yyyy-MM-dd")
  v.before("a", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError == false
  v.before("a", "b", "yyyy-MM-dd")
  v.before("a", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError
  check v.errors["a"][0] == "The a must be a date before 2020-01-01."
  check v.errors["a"][1] == "The a must be a date before 2020-01-01T00:00:00+00:00."

echo "=== before_or_equal"
block:
  let v = newValidation()
  let base = "2020-01-02".parse("yyyy-MM-dd")
  let before = "2020-01-01".parse("yyyy-MM-dd")
  let after = "2020-01-03".parse("yyyy-MM-dd")
  let same = "2020-01-02".parse("yyyy-MM-dd")
  check v.beforeOrEqual(base, after)
  check v.beforeOrEqual(base, same)
  check v.beforeOrEqual(base, before) == false

block:
  let params = Params()
  params["base"] = Param(value:"2020-01-02")
  params["before"] = Param(value:"2020-01-01")
  params["after"] = Param(value:"2020-01-03")
  params["same"] = Param(value:"2020-01-02")
  let v = newRequestValidation(params)
  v.beforeOrEqual("base", "after", "yyyy-MM-dd")
  v.beforeOrEqual("base", "same", "yyyy-MM-dd")
  v.beforeOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError == false
  v.beforeOrEqual("base", "before", "yyyy-MM-dd")
  v.beforeOrEqual("base", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError
  check v.errors["base"][0] == "The base must be a date before or equal to 2020-01-01."
  check v.errors["base"][1] == "The base must be a date before or equal to 2020-01-01T00:00:00+00:00."

echo "=== between"
block:
  let v = newValidation()
  check v.between(2, 1, 3)
  check v.between(1, 2, 3) == false
  check v.between(1.1, 2, 3.1) == false
  check v.between("aaa", 2, 3)
  check v.between("a", 2, 3) == false
  check v.between(["a", "a", "a"], 2, 3)
  check v.between(["a"], 2, 3) == false
  check v.betweenFile("a".repeat(2000), 1, 3)
  check v.betweenFile("a".repeat(2000), 2, 3) == false

block:
  let params = Params()
  params["num"] = Param(value:"2")
  params["str"] = Param(value:"aa")
  params["arr"] = Param(value:"a, b")
  params["file"] = Param(value:"a".repeat(2000), ext:"jpg")
  let v = newRequestValidation(params)
  v.betweenNum("num", 1, 3)
  v.betweenNum("num", 1.1, 3.3)
  v.betweenStr("str", 1, 3)
  v.betweenArr("arr", 1, 3)
  v.betweenFile("file", 1, 3)
  check v.hasError == false
  v.betweenNum("num", 3, 4)
  v.betweenStr("str", 3, 4)
  v.betweenArr("arr", 3, 4)
  v.betweenFile("file", 3, 4)
  check v.hasError
  check v.errors["num"][0] == "The num must be between 3 and 4."
  check v.errors["str"][0] == "The str must be between 3 and 4 characters."
  check v.errors["arr"][0] == "The arr must have between 3 and 4 items."
  check v.errors["file"][0] == "The file must be between 3 and 4 kilobytes."

echo "=== boolean"
block:
  let v = newValidation()
  check v.boolean("true")
  check v.boolean("y")
  check v.boolean("yes")
  check v.boolean("1")
  check v.boolean("on")
  check v.boolean("false")
  check v.boolean("n")
  check v.boolean("no")
  check v.boolean("0")
  check v.boolean("off")
  check v.boolean("a") == false

block:
  let params = Params()
  params["true"] = Param(value:"true")
  params["a"] = Param(value:"a")
  let v = newRequestValidation(params)
  v.boolean("true")
  check v.hasError == false
  v.boolean("a")
  check v.hasError
  check v.errors["a"][0] == "The a field must be true or false."

echo "=== confirmed"
block:
  let v = newValidation()
  check v.confirmed("a", "a")
  check v.confirmed("a", "b") == false

block:
  let params = Params()
  params["password"] = Param(value:"valid")
  params["password_confirmation"] = Param(value:"valid")
  var v = newRequestValidation(params)
  v.confirmed("password")
  check v.hasError == false
  params["password_confirmation"] = Param(value:"invalid")
  v = newRequestValidation(params)
  v.confirmed("password")
  check v.hasError
  check v.errors["password"][0] == "The password confirmation does not match."

echo "=== date"
block:
  let v = newValidation()
  check v.date("2020-01-01", "yyyy-MM-dd")
  check v.date("aaa", "yyyy-MM-dd") == false
  check v.date("1577804400")
  check v.date($high(int))
  check v.date("aaa") == false
  check v.date($high(uint64)) == false

block:
  let params = Params()
  params["valid"] = Param(value:"2020-01-01")
  params["invalid"] = Param(value:"aaa")
  params["validtimestamp"] = Param(value:"1577804400")
  params["negative"] = Param(value:"-1")
  params["invalidtimestamp"] = Param(value:"18446744073709551615")
  let v = newRequestValidation(params)
  v.date("valid", "yyyy-MM-dd")
  v.date("validtimestamp")
  check v.hasError == false
  v.date("invalid", "yyyy-MM-dd")
  v.date("negative")
  v.date("invalidtimestamp")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid is not a valid date."
  check v.errors["negative"][0] == "The negative is not a valid date."
  check v.errors["invalidtimestamp"][0] == "The invalidtimestamp is not a valid date."

echo "=== date_equals"
block:
  let v = newValidation()
  check v.dateEquals("2020-01-01", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
  check v.dateEquals("a", "a", "2020-01-01".parse("yyyy-MM-dd")) == false
  check v.dateEquals("1577880000", "2020-01-01".parse("yyyy-MM-dd"))
  check v.dateEquals("1577980000", "2020-01-01".parse("yyyy-MM-dd")) == false

block:
  let params = Params()
  params["valid_date"] = Param(value:"2020-01-01")
  params["invalid_date"] = Param(value:"a")
  params["valid_timestamp"] = Param(value:"1577880000")
  params["invalid_timestamp"] = Param(value:"1577980000")
  let v = newRequestValidation(params)
  v.dateEquals("valid_date", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
  v.dateEquals("valid_timestamp", "2020-01-01".parse("yyyy-MM-dd"))
  check v.hasError == false
  v.dateEquals("invalid_date", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
  v.dateEquals("invalid_timestamp", "2020-01-01".parse("yyyy-MM-dd"))
  check v.hasError
  check v.errors["invalid_date"][0] == "The invalid_date must be a date equal to 2020-01-01."
  check v.errors["invalid_timestamp"][0] == "The invalid_timestamp must be a date equal to 2020-01-01."

echo "=== different"
block:
  let v = newValidation()
  check v.different("a", "b")
  check v.different("a", "a") == false

block:
  let params = Params()
  params["base"] = Param(value:"a")
  params["valid"] = Param(value:"b")
  params["invalid"] = Param(value:"a")
  let v = newRequestValidation(params)
  v.different("base", "valid")
  check v.hasError == false
  v.different("base", "invalid")
  check v.hasError
  check v.errors["base"][0] == "The base and invalid must be different."

echo "=== digits"
block:
  let v = newValidation()
  check v.digits(11, 2)
  check v.digits(111, 2) == false

block:
  let params = Params()
  params["valid"] = Param(value:"11")
  params["invalid"] = Param(value:"111")
  let v = newRequestValidation(params)
  v.digits("valid", 2)
  check v.hasError == false
  v.digits("invalid", 2)
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be 2 digits."

echo "=== digits_between"
block:
  let v = newValidation()
  check v.digits_between(11, 1, 3)
  check v.digits_between(111, 4, 5) == false

block:
  let params = Params()
  params["valid"] = Param(value:"11")
  params["invalid"] = Param(value:"111")
  let v = newRequestValidation(params)
  v.digits_between("valid", 1, 3)
  check v.hasError == false
  v.digits_between("invalid", 4, 5)
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be between 4 and 5 digits."

echo "=== distinct"
block:
  let v = newValidation()
  check v.distinctArr(@["a", "b", "c"])
  check v.distinctArr(@["a", "b", "b"]) == false

block:
  let params = Params()
  params["valid"] = Param(value:"a, b, c")
  params["invalid"] = Param(value:"a, b, b")
  let v = newRequestValidation(params)
  v.distinctArr("valid")
  check v.hasError == false
  v.distinctArr("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid field has a duplicate value."

echo "=== domain"
block:
  let v = newValidation()
  check v.domain("aaa.co.jp")
  check not v.domain("#%&'/=~`*+?{}^$-|.com")

block:
  let params = Params()
  params["valid"] = Param(value:"aaa.co.jp")
  params["invalid"] = Param(value:"#%&'/=~`*+?{}^$-|.com")
  let v = newRequestValidation(params)
  v.domain("valid")
  check v.hasError == false
  v.domain("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be a valid domain."

echo "=== email"
block:
  let v = newValidation()
  check v.email("email@domain.com")
  check not v.email("Abc.@example.com")

block:
  let params = Params()
  params["valid"] = Param(value:"email@domain.com")
  params["invalid"] = Param(value:"Abc.@example.com")
  let v = newRequestValidation(params)
  v.email("valid")
  check v.hasError == false
  v.email("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be a valid email address."