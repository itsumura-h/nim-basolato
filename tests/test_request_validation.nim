discard """
"""

import unittest, times
include ../../src/basolato/core/request
include ../../src/basolato/request_validation

block:
  let v = newValidation()
  check v.accepted("on")
  check v.accepted("yes")
  check v.accepted("1")
  check v.accepted("true")
  check v.accepted("a") == false

block:
  let p = Params()
  p["on"] = Param(value:"on")
  p["yes"] = Param(value:"yes")
  p["one"] = Param(value:"1")
  p["true"] = Param(value:"true")
  p["invalid"] = Param(value:"invalid")
  var v = newRequestValidation(p)
  v.accepted("on")
  v.accepted("yes")
  v.accepted("one")
  v.accepted("true")
  check v.hasError == false

  v.accepted("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be accepted."


block:
  let v = newValidation()
  check v.domain("domain.com")
  check v.domain("[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]")
  check v.domain("[2001:0db8:bd05:01d2:288a::1fc0:0001:10ee]") == false

block:
  let p = Params()
  p["a"] = Param(value:"domain.com")
  p["b"] = Param(value:"[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]")
  p["c"] = Param(value:"[2001:0db8:bd05:01d2:288a::1fc0:0001:10ee]")
  let v = newRequestValidation(p)
  v.domain("a")
  v.domain("b")
  check v.hasError == false

  v.domain("c")
  check v.hasError
  check v.errors["c"][0] == "The c must be a valid domain."


block:
  let v = newValidation()
  let a = "2020-01-02".parse("yyyy-MM-dd")
  let b = "2020-01-01".parse("yyyy-MM-dd")
  let c = "2020-01-03".parse("yyyy-MM-dd")
  check v.after(a, b)
  check v.after(a, c) == false

block:
  let p = Params()
  p["a"] = Param(value:"2020-01-02")
  p["b"] = Param(value:"2020-01-01")
  p["c"] = Param(value:"2020-01-03")
  let v = newRequestValidation(p)
  v.after("a", "b", "yyyy-MM-dd")
  v.after("a", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError == false
  v.after("a", "c", "yyyy-MM-dd")
  v.after("a", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError
  check v.errors["a"][0] == "The a must be a date after 2020-01-03."
  check v.errors["a"][1] == "The a must be a date after 2020-01-03T00:00:00+00:00."

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
  let p = Params()
  p["base"] = Param(value:"2020-01-02")
  p["before"] = Param(value:"2020-01-01")
  p["after"] = Param(value:"2020-01-03")
  p["same"] = Param(value:"2020-01-02")
  let v = newRequestValidation(p)
  v.afterOrEqual("base", "before", "yyyy-MM-dd")
  v.afterOrEqual("base", "same", "yyyy-MM-dd")
  v.afterOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError == false
  v.afterOrEqual("base", "after", "yyyy-MM-dd")
  v.afterOrEqual("base", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError
  check v.errors["base"][0] == "The base must be a date after or equal to 2020-01-03."
  check v.errors["base"][1] == "The base must be a date after or equal to 2020-01-03T00:00:00+00:00."

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
  let p = Params()
  p["small"] = Param(value:"abcdefghijklmnopqrstuvwxyz")
  p["large"] = Param(value:"ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  p["number"] = Param(value:"1234567890")
  p["mark"] = Param(value:"!\"#$%&'()~=~|`{}*+<>?_@[]:;,./^-")
  p["ja"] = Param(value:"あいうえお")
  let v = newRequestValidation(p)
  v.alpha("small")
  v.alpha("large")
  check v.hasError == false
  v.alpha("number")
  v.alpha("mark")
  v.alpha("ja")
  check v.errors["number"][0] == "The number may only contain letters."
  check v.errors["mark"][0] == "The mark may only contain letters."
  check v.errors["ja"][0] == "The ja may only contain letters."


block:
  let v = newValidation()
  const letter = "abcAbc012"
  const withDash = "abcAbc012-_"
  const ja = "aA0あいうえお"
  check v.alphaDash(letter)
  check v.alphaDash(withDash)
  check v.alphaDash(ja) == false

block:
  let p = Params()
  p["letter"] = Param(value:"abcABC012")
  p["withDash"] = Param(value:"abcABC012-_")
  p["ja"] = Param(value:"aA0あいうえお")
  let v = newRequestValidation(p)
  v.alphaDash("letter")
  v.alphaDash("withDash")
  check v.hasError == false
  v.alphaDash("ja")
  check v.hasError
  check v.errors["ja"][0] == "The ja may only contain letters, numbers, dashes and underscores."


block:
  let v = newValidation()
  const letter = "abcABC012"
  const withDash = "abcABC012-_"
  const ja = "aA0あいうえお"
  check v.alphaNum(letter)
  check v.alphaNum(withDash) == false
  check v.alphaNum(ja) == false

block:
  let p = Params()
  p["letter"] = Param(value:"abcABC012")
  p["withDash"] = Param(value:"abcABC012-_")
  p["ja"] = Param(value:"aA0あいうえお")
  let v = newRequestValidation(p)
  v.alphaNum("letter")
  check v.hasError == false
  v.alphaNum("withDash")
  v.alphaNum("ja")
  check v.hasError
  check v.errors["withDash"][0] == "The withDash may only contain letters and numbers."
  check v.errors["ja"][0] == "The ja may only contain letters and numbers."

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
  let p = Params()
  p["valid"] = Param(value:"a, b, c")
  p["dict"] = Param(value:"""{"a": "a", "b": "b"}""")
  p["kv"] = Param(value:"a=a, b=b")
  p["str"] = Param(value:"adaddadad")
  p["number"] = Param(value:"1313193")

  let v = newRequestValidation(p)
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


block:
  let v = newValidation()
  let a = "2020-01-02".parse("yyyy-MM-dd")
  let b = "2020-01-01".parse("yyyy-MM-dd")
  let c = "2020-01-03".parse("yyyy-MM-dd")
  check v.before(a, c)
  check v.before(a, b) == false

block:
  let p = Params()
  p["a"] = Param(value:"2020-01-02")
  p["b"] = Param(value:"2020-01-01")
  p["c"] = Param(value:"2020-01-03")
  let v = newRequestValidation(p)
  v.before("a", "c", "yyyy-MM-dd")
  v.before("a", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError == false
  v.before("a", "b", "yyyy-MM-dd")
  v.before("a", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError
  check v.errors["a"][0] == "The a must be a date before 2020-01-01."
  check v.errors["a"][1] == "The a must be a date before 2020-01-01T00:00:00+00:00."


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
  let p = Params()
  p["base"] = Param(value:"2020-01-02")
  p["before"] = Param(value:"2020-01-01")
  p["after"] = Param(value:"2020-01-03")
  p["same"] = Param(value:"2020-01-02")
  let v = newRequestValidation(p)
  v.beforeOrEqual("base", "after", "yyyy-MM-dd")
  v.beforeOrEqual("base", "same", "yyyy-MM-dd")
  v.beforeOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError == false
  v.beforeOrEqual("base", "before", "yyyy-MM-dd")
  v.beforeOrEqual("base", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasError
  check v.errors["base"][0] == "The base must be a date before or equal to 2020-01-01."
  check v.errors["base"][1] == "The base must be a date before or equal to 2020-01-01T00:00:00+00:00."

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
  let p = Params()
  p["num"] = Param(value:"2")
  p["str"] = Param(value:"aa")
  p["arr"] = Param(value:"a, b")
  p["file"] = Param(value:"a".repeat(2000), ext:"jpg")
  let v = newRequestValidation(p)
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
  let p = Params()
  p["true"] = Param(value:"true")
  p["a"] = Param(value:"a")
  let v = newRequestValidation(p)
  v.boolean("true")
  check v.hasError == false
  v.boolean("a")
  check v.hasError
  check v.errors["a"][0] == "The a field must be true or false."

block:
  let p = Params()
  p["password"] = Param(value:"valid")
  p["password_confirmation"] = Param(value:"valid")
  var v = newRequestValidation(p)
  v.confirmed("password")
  check v.hasError == false
  p["password_confirmation"] = Param(value:"invalid")
  v = newRequestValidation(p)
  v.confirmed("password")
  check v.hasError
  check v.errors["password"][0] == "The password confirmation does not match."

block:
  let v = newValidation()
  check v.date("2020-01-01", "yyyy-MM-dd")
  check v.date("aaa", "yyyy-MM-dd") == false
  check v.date("1577804400")
  check v.date($high(int))
  check v.date("aaa") == false
  check v.date($high(uint64)) == false

block:
  let p = Params()
  p["valid"] = Param(value:"2020-01-01")
  p["invalid"] = Param(value:"aaa")
  p["validtimestamp"] = Param(value:"1577804400")
  p["negative"] = Param(value:"-1")
  p["invalidtimestamp"] = Param(value:"18446744073709551615")
  let v = newRequestValidation(p)
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

block:
  let v = newValidation()
  check v.dateEquals("2020-01-01", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
  check v.dateEquals("a", "a", "2020-01-01".parse("yyyy-MM-dd")) == false
  check v.dateEquals("1577880000", "2020-01-01".parse("yyyy-MM-dd"))
  check v.dateEquals("1577980000", "2020-01-01".parse("yyyy-MM-dd")) == false

block:
  let p = Params()
  p["valid_date"] = Param(value:"2020-01-01")
  p["invalid_date"] = Param(value:"a")
  p["valid_timestamp"] = Param(value:"1577880000")
  p["invalid_timestamp"] = Param(value:"1577980000")
  let v = newRequestValidation(p)
  v.dateEquals("valid_date", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
  v.dateEquals("valid_timestamp", "2020-01-01".parse("yyyy-MM-dd"))
  check v.hasError == false
  v.dateEquals("invalid_date", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
  v.dateEquals("invalid_timestamp", "2020-01-01".parse("yyyy-MM-dd"))
  check v.hasError
  check v.errors["invalid_date"][0] == "The invalid_date must be a date equal to 2020-01-01."
  check v.errors["invalid_timestamp"][0] == "The invalid_timestamp must be a date equal to 2020-01-01."


block:
  let v = newValidation()
  check v.different("a", "b")
  check v.different("a", "a") == false

block:
  let p = Params()
  p["base"] = Param(value:"a")
  p["valid"] = Param(value:"b")
  p["invalid"] = Param(value:"a")
  let v = newRequestValidation(p)
  v.different("base", "valid")
  check v.hasError == false
  v.different("base", "invalid")
  check v.hasError
  check v.errors["base"][0] == "The base and invalid must be different."


block:
  let v = newValidation()
  check v.digits(11, 2)
  check v.digits(111, 2) == false

block:
  let p = Params()
  p["valid"] = Param(value:"11")
  p["invalid"] = Param(value:"111")
  let v = newRequestValidation(p)
  v.digits("valid", 2)
  check v.hasError == false
  v.digits("invalid", 2)
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be 2 digits."


block:
  let v = newValidation()
  check v.digits_between(11, 1, 3)
  check v.digits_between(111, 4, 5) == false

block:
  let p = Params()
  p["valid"] = Param(value:"11")
  p["invalid"] = Param(value:"111")
  let v = newRequestValidation(p)
  v.digits_between("valid", 1, 3)
  check v.hasError == false
  v.digits_between("invalid", 4, 5)
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be between 4 and 5 digits."


block:
  let v = newValidation()
  check v.distinctArr(@["a", "b", "c"])
  check v.distinctArr(@["a", "b", "b"]) == false

block:
  let p = Params()
  p["valid"] = Param(value:"a, b, c")
  p["invalid"] = Param(value:"a, b, b")
  let v = newRequestValidation(p)
  v.distinctArr("valid")
  check v.hasError == false
  v.distinctArr("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid field has a duplicate value."


block:
  let v = newValidation()
  check v.domain("aaa.co.jp")
  check not v.domain("#%&'/=~`*+?{}^$-|.com")

block:
  let p = Params()
  p["valid"] = Param(value:"aaa.co.jp")
  p["invalid"] = Param(value:"#%&'/=~`*+?{}^$-|.com")
  let v = newRequestValidation(p)
  v.domain("valid")
  check v.hasError == false
  v.domain("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be a valid domain."


block:
  let v = newValidation()
  check v.email("email@domain.com")
  check not v.email("Abc.@example.com")

block:
  let p = Params()
  p["valid"] = Param(value:"email@domain.com")
  p["invalid"] = Param(value:"Abc.@example.com")
  let v = newRequestValidation(p)
  v.email("valid")
  check v.hasError == false
  v.email("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be a valid email address."


block:
  let v = newValidation()
  check v.endsWith("abcdefg", "fg")
  check v.endsWith("abcdefg", "gh") == false

block:
  let p = Params()
  p["item"] = Param(value:"abcdefg")
  let v = newRequestValidation(p)
  v.endsWith("item", "fg")
  check v.hasError == false
  v.endsWith("item", "gh")
  check v.hasError
  check v.errors["item"][0] == "The item must be end with one of following gh."


block:
  let v = newValidation()
  check v.file("aaa", "jpg")
  check v.file("aaa", "") == false

block:
  let p = Params()
  p["valid"] = Param(value:"a", ext:"jpg")
  p["invalid"] = Param(value:"a")
  let v = newRequestValidation(p)
  v.file("valid")
  check v.hasError == false
  v.file("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be a file."



block:
  let v = newValidation()
  check v.filled("a")
  check v.filled("") == false

block:
  let p = Params()
  p["valid"] = Param(value:"a")
  p["invalid"] = Param(value:"")
  let v = newRequestValidation(p)
  v.filled("valid")
  check v.hasError == false
  v.filled("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid field must have a value."



block:
  let v = newValidation()
  check v.gt(2, 1)
  check v.gt(2, 3) == false
  check v.gt("ab", "a")
  check v.gt("ab", "abc") == false
  check v.gt(["a", "b"], ["a"])
  check v.gt(["a", "b"], ["a", "b", "c"]) == false

block:
  let p = Params()
  p["base"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  let v = newRequestValidation(p)
  v.gtNum("base", "smaller")
  check v.hasError == false
  v.gtNum("base", "bigger")
  check v.hasError
  check v.errors["base"][0] == "The base must be greater than bigger."

block:
  let p = Params()
  p["base"] = Param(value:"ab", ext:"jpg")
  p["smaller"] = Param(value:"a", ext:"jpg")
  p["bigger"] = Param(value:"abc", ext:"jpg")
  let v = newRequestValidation(p)
  v.gtFile("base", "smaller")
  check v.hasError == false
  v.gtFile("base", "bigger")
  check v.hasError
  check v.errors["base"][0] == "The base must be greater than 0.0029296875 kilobytes."

block:
  let p = Params()
  p["base"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  let v = newRequestValidation(p)
  v.gtStr("base", "smaller")
  check v.hasError == false
  v.gtStr("base", "bigger")
  check v.hasError
  check v.errors["base"][0] == "The base must be greater than bigger characters."

block:
  let p = Params()
  p["base"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  let v = newRequestValidation(p)
  v.gtArr("base", "smaller")
  check v.hasError == false
  v.gtArr("base", "bigger")
  check v.hasError
  check v.errors["base"][0] == "The base must have more than bigger items."



block:
  let v = newValidation()
  check v.gte(2, 1)
  check v.gte(2, 2)
  check v.gte(2, 3) == false
  check v.gte("ab", "a")
  check v.gte("ab", "aa")
  check v.gte("ab", "abc") == false
  check v.gte(["a", "b"], ["a"])
  check v.gte(["a", "b"], ["a", "b"])
  check v.gte(["a", "b"], ["a", "b", "c"]) == false

block:
  let p = Params()
  p["base"] = Param(value:"2")
  p["same"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  let v = newRequestValidation(p)
  v.gteNum("base", "smaller")
  v.gteNum("base", "same")
  check v.hasError == false
  v.gteNum("base", "bigger")
  check v.hasError
  check v.errors["base"][0] == "The base must be greater than or equal bigger."

block:
  let p = Params()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["same"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["smaller"] = Param(value:"a".repeat(1*1024), ext:"jpg")
  p["bigger"] = Param(value:"a".repeat(3*1024), ext:"jpg")
  let v = newRequestValidation(p)
  v.gteFile("base", "smaller")
  v.gteFile("base", "same")
  check v.hasError == false
  v.gteFile("base", "bigger")
  check v.hasError
  check v.errors["base"][0] == "The base must be greater than or equal 3 kilobytes."

block:
  let p = Params()
  p["base"] = Param(value:"ab")
  p["same"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  let v = newRequestValidation(p)
  v.gteStr("base", "smaller")
  v.gteStr("base", "same")
  check v.hasError == false
  v.gteStr("base", "bigger")
  check v.hasError
  check v.errors["base"][0] == "The base must be greater than or equal bigger characters."

block:
  let p = Params()
  p["base"] = Param(value:"a, b")
  p["same"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  let v = newRequestValidation(p)
  v.gteArr("base", "smaller")
  v.gteArr("base", "same")
  check v.hasError == false
  v.gteArr("base", "bigger")
  check v.hasError
  check v.errors["base"][0] == "The base must have bigger items or more."


block:
  let v = newValidation()
  check v.image("jpg")
  check v.image("nim") == false

block:
  let p = Params()
  p["valid"] = Param(ext:"jpg")
  p["invalid"] = Param(ext:"nim")
  let v = newRequestValidation(p)
  v.image("valid")
  check v.hasError == false
  v.image("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be an image."


block:
  let v = Validation()
  check v.in("a", ["a", "b"])
  check v.in("c", ["a", "b"]) == false

block:
  let p = Params()
  p["valid"] = Param(value:"a")
  p["invalid"] = Param(value:"c")
  let v = newRequestValidation(p)
  v.in("valid", ["a", "b"])
  check v.hasError == false
  v.in("invalid", ["a", "b"])
  check v.hasError
  check v.errors["invalid"][0] == "The selected invalid is invalid."


block:
  let p = Params()
  p["base"] = Param(value:"a")
  p["valid"] = Param(value:"a, b, c")
  p["invalid"] = Param(value:"b, c")
  let v = newRequestValidation(p)
  v.inArray("base", "valid")
  check v.hasError == false
  v.inArray("base", "invalid")
  check v.hasError
  check v.errors["base"][0] == "The base field does not exist in invalid."



block:
  let v = Validation()
  check v.integer("1")
  check v.integer("1686246286")
  check v.integer("a") == false

block:
  let p = Params()
  p["valid"] = Param(value:"1")
  p["invalid"] = Param(value:"a")
  let v = newRequestValidation(p)
  v.integer("valid")
  check v.hasError == false
  v.integer("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be an integer."


block:
  let v = Validation()
  check v.json("""{"str": "value", "int": 1, "float": 1.1, "bool": true}""")
  check v.json("a") == false

block:
  let p = Params()
  p["valid"] = Param(value:"""{"key": "value"}""")
  p["invalid"] = Param(value:"a")
  let v = newRequestValidation(p)
  v.json("valid")
  check v.hasError == false
  v.json("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be a valid JSON string."



block:
  let v = newValidation()
  check v.lt(2, 3)
  check v.lt(2, 1) == false
  check v.lt("ab", "abc")
  check v.lt("ab", "ab") == false
  check v.lt(["a", "b"], ["a", "b", "c"])
  check v.lt(["a", "b"], ["a"]) == false

block:
  let p = Params()
  p["base"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  let v = newRequestValidation(p)
  v.ltNum("base", "bigger")
  check v.hasError == false
  v.ltNum("base", "smaller")
  check v.hasError
  check v.errors["base"][0] == "The base must be less than smaller."

block:
  let p = Params()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["smaller"] = Param(value:"a".repeat(1*1024), ext:"jpg")
  p["bigger"] = Param(value:"a".repeat(3*1024), ext:"jpg")
  let v = newRequestValidation(p)
  v.ltFile("base", "bigger")
  check v.hasError == false
  v.ltFile("base", "smaller")
  check v.hasError
  check v.errors["base"][0] == "The base must be less than 1.0 kilobytes."

block:
  let p = Params()
  p["base"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  let v = newRequestValidation(p)
  v.ltStr("base", "bigger")
  check v.hasError == false
  v.ltStr("base", "smaller")
  check v.hasError
  check v.errors["base"][0] == "The base must be less than smaller characters."

block:
  let p = Params()
  p["base"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  let v = newRequestValidation(p)
  v.ltArr("base", "bigger")
  check v.hasError == false
  v.ltArr("base", "smaller")
  check v.hasError
  check v.errors["base"][0] == "The base must have less than smaller items."



block:
  let v = newValidation()
  check v.lte(2, 3)
  check v.lte(2, 2)
  check v.lte(2, 1) == false
  check v.lte("ab", "abc")
  check v.lte("ab", "aa")
  check v.lte("ab", "a") == false
  check v.lte(["a", "b"], ["a", "b", "c"])
  check v.lte(["a", "b"], ["a", "b"])
  check v.lte(["a", "b"], ["a"]) == false

block:
  let p = Params()
  p["base"] = Param(value:"2")
  p["same"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  let v = newRequestValidation(p)
  v.lteNum("base", "bigger")
  v.lteNum("base", "same")
  check v.hasError == false
  v.lteNum("base", "smaller")
  check v.hasError
  check v.errors["base"][0] == "The base must be less than or equal smaller."

block:
  let p = Params()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["same"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["smaller"] = Param(value:"a".repeat(1*1024), ext:"jpg")
  p["bigger"] = Param(value:"a".repeat(3*1024), ext:"jpg")
  let v = newRequestValidation(p)
  v.lteFile("base", "bigger")
  v.lteFile("base", "same")
  check v.hasError == false
  v.lteFile("base", "smaller")
  check v.hasError
  check v.errors["base"][0] == "The base must be less than or equal 1 kilobytes."

block:
  let p = Params()
  p["base"] = Param(value:"ab")
  p["same"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  let v = newRequestValidation(p)
  v.lteStr("base", "bigger")
  v.lteStr("base", "same")
  check v.hasError == false
  v.lteStr("base", "smaller")
  check v.hasError
  check v.errors["base"][0] == "The base must be less than or equal smaller characters."

block:
  let p = Params()
  p["base"] = Param(value:"a, b")
  p["same"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  let v = newRequestValidation(p)
  v.lteArr("base", "bigger")
  v.lteArr("base", "same")
  check v.hasError == false
  v.lteArr("base", "smaller")
  check v.hasError
  check v.errors["base"][0] == "The base must not have more than smaller items."


block:
  let v = Validation()
  check v.max(2, 3)
  check v.max(2, 1) == false
  check v.max("ab", 3)
  check v.max("ab", 1) == false
  check v.max(["a", "b"], 3)
  check v.max(["a", "b"], 1) == false

block:
  let p = Params()
  p["base"] = Param(value:"2")
  let v = newRequestValidation(p)
  v.maxNum("base", 3)
  v.maxNum("base", 2)
  check v.hasError == false
  v.maxNum("base", 1)
  check v.hasError
  check v.errors["base"][0] == "The base may not be greater than 1."

block:
  let p = Params()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  let v = newRequestValidation(p)
  v.maxFile("base", 3)
  v.maxFile("base", 2)
  check v.hasError == false
  v.maxFile("base", 1)
  check v.hasError
  check v.errors["base"][0] == "The base may not be greater than 1 kilobytes."

block:
  let p = Params()
  p["base"] = Param(value:"ab")
  let v = newRequestValidation(p)
  v.maxStr("base", 3)
  v.maxStr("base", 2)
  check v.hasError == false
  v.maxStr("base", 1)
  check v.hasError
  check v.errors["base"][0] == "The base may not be greater than 1 characters."

block:
  let p = Params()
  p["base"] = Param(value:"a, b")
  let v = newRequestValidation(p)
  v.maxArr("base", 3)
  v.maxArr("base", 2)
  check v.hasError == false
  v.maxArr("base", 1)
  check v.hasError
  check v.errors["base"][0] == "The base may not have more than 1 items."


block:
  let v = Validation()
  check v.mimes("jpg", ["jpg", "png", "gif"])
  check v.mimes("mp4", ["jpg", "png", "gif"]) == false

block:
  let p = Params()
  p["valid"] = Param(value:"a", ext:"jpg")
  p["invalid"] = Param(value:"a", ext:"mp4")
  let v = newRequestValidation(p)
  v.mimes("valid", ["jpg", "png", "gif"])
  check v.hasError == false
  v.mimes("invalid", ["jpg", "png", "gif"])
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be a file of type: [\"jpg\", \"png\", \"gif\"]."


block:
  let v = Validation()
  check v.min(2, 1)
  check v.min(2, 3) == false
  check v.min("ab", 1)
  check v.min("ab", 3) == false
  check v.min(["a", "b"], 1)
  check v.min(["a", "b"], 3) == false

block:
  let p = Params()
  p["base"] = Param(value:"2")
  let v = newRequestValidation(p)
  v.minNum("base", 1)
  v.minNum("base", 2)
  check v.hasError == false
  v.minNum("base", 3)
  check v.hasError
  check v.errors["base"][0] == "The base must be at least 3."

block:
  let p = Params()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  let v = newRequestValidation(p)
  v.minFile("base", 1)
  v.minFile("base", 2)
  check v.hasError == false
  v.minFile("base", 3)
  check v.hasError
  check v.errors["base"][0] == "The base must be at least 3 kilobytes."

block:
  let p = Params()
  p["base"] = Param(value:"ab")
  let v = newRequestValidation(p)
  v.minStr("base", 1)
  v.minStr("base", 2)
  check v.hasError == false
  v.minStr("base", 3)
  check v.hasError
  check v.errors["base"][0] == "The base must be at least 3 characters."

block:
  let p = Params()
  p["base"] = Param(value:"a, b")
  let v = newRequestValidation(p)
  v.minArr("base", 1)
  v.minArr("base", 2)
  check v.hasError == false
  v.minArr("base", 3)
  check v.hasError
  check v.errors["base"][0] == "The base must have at least 3 items."



block:
  let v = Validation()
  check v.notIn("a", ["b", "c"])
  check v.notIn("b", ["b", "c"]) == false

block:
  let p = Params()
  p["valid"] = Param(value:"a")
  p["invalid"] = Param(value:"b")
  let v = newRequestValidation(p)
  v.notIn("valid", ["b", "c"])
  check v.hasError == false
  v.notIn("invalid", ["b", "c"])
  check v.hasError
  check v.errors["invalid"][0] == "The selected invalid is invalid."



block:
  let v =Validation()
  check v.notRegex("abc", re"\d")
  check v.notRegex("abc", re"\w") == false

block:
  let p = Params()
  p["base"] = Param(value:"abc")
  let v = newRequestValidation(p)
  v.notRegex("base", re"\d")
  check v.hasError == false
  v.notRegex("base", re"\w")
  check v.hasError
  check v.errors["base"][0] == "The base format is invalid."



block:
  let v = Validation()
  check v.numeric("-1.23")
  check v.numeric("abc") == false

block:
  let p = Params()
  p["valid"] = Param(value:"-1.23")
  p["invalid"] = Param(value:"abc")
  let v = newRequestValidation(p)
  v.numeric("valid")
  check v.hasError == false
  v.numeric("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be a number."



block:
  let p = Params()
  p["valid"] = Param(value:"a")
  let v = newRequestValidation(p)
  v.present("valid")
  check v.hasError == false
  v.present("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid field must be present."



block:
  let v = Validation()
  check v.regex("abc", re"\w")
  check v.regex("abc", re"\d") == false

block:
  let p = Params()
  p["base"] = Param(value:"abc")
  let v = newRequestValidation(p)
  v.regex("base", re"\w")
  check v.hasError == false
  v.regex("base", re"\d")
  check v.hasError
  check v.errors["base"][0] == "The base format is invalid."



block:
  let v = Validation()
  check v.required("abc")
  check v.required("") == false
  check v.required("null") == false



block:
  let p = Params()
  p["other"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = newRequestValidation(p)
  v.requiredIf("valid", "other", ["123"])
  v.requiredIf("valid", "other", ["abc"])
  check v.hasError == false
  v.requiredIf("invalid1", "other", ["123"])
  v.requiredIf("invalid2", "other", ["123"])
  check v.hasError
  check v.errors["invalid1"][0] == "The invalid1 field is required when other is 123."
  check v.errors["invalid2"][0] == "The invalid2 field is required when other is 123."


block:
  let p = Params()
  p["other"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = newRequestValidation(p)
  v.requiredUnless("valid", "other", ["123"])
  v.requiredUnless("valid", "other", ["abc"])
  check v.hasError == false
  v.requiredUnless("invalid1", "other", ["abc"])
  v.requiredUnless("invalid2", "other", ["abc"])
  check v.hasError
  check v.errors["invalid1"][0] == "The invalid1 field is required unless other is in [\"abc\"]."
  check v.errors["invalid2"][0] == "The invalid2 field is required unless other is in [\"abc\"]."


block:
  let p = Params()
  p["other"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = newRequestValidation(p)
  v.requiredWith("valid", ["a"])
  v.requiredWith("valid", ["other"])
  check v.hasError == false
  v.requiredWith("invalid1", ["other"])
  v.requiredWith("invalid2", ["other"])
  check v.hasError
  check v.errors["invalid1"][0] == "The invalid1 field is required when [\"other\"] is present."
  check v.errors["invalid2"][0] == "The invalid2 field is required when [\"other\"] is present."



block:
  let p = Params()
  p["other1"] = Param(value:"123")
  p["other2"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = newRequestValidation(p)
  v.requiredWithAll("valid", ["other1", "other2"])
  v.requiredWithAll("invalid1", ["notExists"])
  check v.hasError == false
  v.requiredWithAll("invalid1", ["other1", "other2"])
  v.requiredWithAll("invalid2", ["other1", "other2"])
  check v.hasError
  check v.errors["invalid1"][0] == "The invalid1 field is required when [\"other1\", \"other2\"] are present."
  check v.errors["invalid2"][0] == "The invalid2 field is required when [\"other1\", \"other2\"] are present."



block:
  let p = Params()
  p["other1"] = Param(value:"123")
  p["other2"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = newRequestValidation(p)
  v.requiredWithout("valid", ["other1", "other2"])
  v.requiredWithout("valid", ["notExists"])
  check v.hasError == false
  v.requiredWithout("invalid1", ["other1", "aaa"])
  v.requiredWithout("invalid2", ["other1", "aaa"])
  check v.hasError
  check v.errors["invalid1"][0] == "The invalid1 field is required when [\"other1\", \"aaa\"] is not present."
  check v.errors["invalid2"][0] == "The invalid2 field is required when [\"other1\", \"aaa\"] is not present."



block:
  let p = Params()
  p["valid"] = Param(value:"abc")
  p["other"] = Param(value:"123")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = newRequestValidation(p)
  v.requiredWithoutAll("valid", ["aaa", "bbb"])
  v.requiredWithoutAll("invalid1", ["other"])
  check v.hasError == false
  v.requiredWithoutAll("invalid1", ["aaa", "bbb"])
  v.requiredWithoutAll("invalid2", ["aaa", "bbb"])
  check v.hasError
  check v.errors["invalid1"][0] == "The invalid1 field is required when none of [\"aaa\", \"bbb\"] are present."
  check v.errors["invalid2"][0] == "The invalid2 field is required when none of [\"aaa\", \"bbb\"] are present."


block:
  let v = Validation()
  check v.same("a", "a")
  check v.same("a", "b") == false

block:
  let p = Params()
  p["a"] = Param(value:"a")
  p["b"] = Param(value:"a")
  p["c"] = Param(value:"c")
  let v = newRequestValidation(p)
  v.same("a", "b")
  check v.hasError == false
  v.same("a", "c")
  check v.hasError
  check v.errors["a"][0] == "The a and c must match."


block:
  let v = Validation()
  check v.size(1, 1)
  check v.size(1, 2) == false
  check v.size("a", 1)
  check v.size("a", 2) == false
  check v.sizeFile("a".repeat(1025), 1)
  check v.sizeFile("a".repeat(2048), 1) == false
  check v.size(["a"], 1)
  check v.size(["a"], 2) == false

block:
  let p = Params()
  p["num"] = Param(value:"2")
  p["file"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["str"] = Param(value:"ab")
  p["arr"] = Param(value:"a, b")
  let v = newRequestValidation(p)
  v.sizeNum("num", 2)
  v.sizeFile("file", 2)
  v.sizeStr("str", 2)
  v.sizeArr("arr", 2)
  check v.hasError == false
  v.sizeNum("num", 1)
  v.sizeFile("file", 1)
  v.sizeStr("str", 1)
  v.sizeArr("arr", 1)
  check v.hasError
  check v.errors["num"][0] == "The num must be 1."
  check v.errors["file"][0] == "The file must be 1 kilobytes."
  check v.errors["str"][0] == "The str must be 1 characters."
  check v.errors["arr"][0] == "The arr must contain 1 items."


block:
  let v = Validation()
  check v.startsWith("abcde", ["abc", "bcd"])
  check v.startsWith("abcde", ["bcd", "cde"]) == false

block:
  let p = Params()
  p["base"] = Param(value:"abcde")
  let v = newRequestValidation(p)
  v.startsWith("base", ["abc", "bcd"])
  check v.hasError == false
  v.startsWith("base", ["bcd", "cde"])
  check v.hasError
  check v.errors["base"][0] == "The base must be start with one of following [\"bcd\", \"cde\"]."



block:
  let v = Validation()
  check v.url("https://google.com:8000/xxx/yyy/zzz?key=value")
  check v.url("fnyuaAxmoiniancywcnsnmuaic") == false

block:
  let p = Params()
  p["valid"] = Param(value:"https://google.com:8000/xxx/yyy/zzz?key=value")
  p["invalid"] = Param(value:"fnyuaAxmoiniancywcnsnmuaic")
  let v = newRequestValidation(p)
  v.url("valid")
  check v.hasError == false
  v.url("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid format is invalid."


block:
  let v = Validation()
  check v.uuid("a0a2a2d2-0b87-4a18-83f2-2529882be2de")
  check v.uuid("aiuimacuca") == false

block:
  let p = Params()
  p["valid"] = Param(value:"a0a2a2d2-0b87-4a18-83f2-2529882be2de")
  p["invalid"] = Param(value:"iuajfassacds")
  let v = newRequestValidation(p)
  v.uuid("valid")
  check v.hasError == false
  v.uuid("invalid")
  check v.hasError
  check v.errors["invalid"][0] == "The invalid must be a valid UUID."
