discard """
"""

import unittest, times
include ../src/basolato/core/request
include ../src/basolato/request_validation

block:
  let p = newParams()
  p["on"] = Param(value:"on")
  p["yes"] = Param(value:"yes")
  p["one"] = Param(value:"1")
  p["true"] = Param(value:"true")
  p["invalid"] = Param(value:"invalid")
  p.accepted("on")
  p.accepted("yes")
  p.accepted("one")
  p.accepted("true")
  p.accepted(["on", "yes", "one", "true"])
  check p.hasErrors == false

  p.accepted("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be accepted."

block:
  let p = newParams()
  p["a"] = Param(value:"2020-01-02")
  p["b"] = Param(value:"2020-01-01")
  p["c"] = Param(value:"2020-01-03")
  p.after("a", "b", "yyyy-MM-dd")
  p.after("a", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check p.hasErrors == false
  p.after("a", "c", "yyyy-MM-dd")
  p.after("a", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check p.hasErrors
  check p.errors["a"][0] == "The a must be a date after 2020-01-03."
  check p.errors["a"][1] == "The a must be a date after 2020-01-03T00:00:00+00:00."

block:
  let p = newParams()
  p["base"] = Param(value:"2020-01-02")
  p["before"] = Param(value:"2020-01-01")
  p["after"] = Param(value:"2020-01-03")
  p["same"] = Param(value:"2020-01-02")
  p.afterOrEqual("base", "before", "yyyy-MM-dd")
  p.afterOrEqual("base", "same", "yyyy-MM-dd")
  p.afterOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check p.hasErrors == false
  p.afterOrEqual("base", "after", "yyyy-MM-dd")
  p.afterOrEqual("base", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be a date after or equal to 2020-01-03."
  check p.errors["base"][1] == "The base must be a date after or equal to 2020-01-03T00:00:00+00:00."

block:
  let p = newParams()
  p["small"] = Param(value:"abcdefghijklmnopqrstuvwxyz")
  p["large"] = Param(value:"ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  p["number"] = Param(value:"1234567890")
  p["mark"] = Param(value:"!\"#$%&'()~=~|`{}*+<>?_@[]:;,./^-")
  p["ja"] = Param(value:"あいうえお")
  p.alpha("small")
  p.alpha("large")
  p.alpha(["small", "large"])
  check p.hasErrors == false
  p.alpha("number")
  p.alpha("mark")
  p.alpha("ja")
  check p.errors["number"][0] == "The number may only contain letters."
  check p.errors["mark"][0] == "The mark may only contain letters."
  check p.errors["ja"][0] == "The ja may only contain letters."

block:
  let p = newParams()
  p["letter"] = Param(value:"abcABC012")
  p["withDash"] = Param(value:"abcABC012-_")
  p["ja"] = Param(value:"aA0あいうえお")
  p.alphaDash("letter")
  p.alphaDash("withDash")
  p.alphaDash(["letter", "withDash"])
  check p.hasErrors == false
  p.alphaDash("ja")
  check p.hasErrors
  check p.errors["ja"][0] == "The ja may only contain letters, numbers, dashes and underscores."


block:
  let p = newParams()
  p["letter"] = Param(value:"abcABC012")
  p["withDash"] = Param(value:"abcABC012-_")
  p["ja"] = Param(value:"aA0あいうえお")
  p.alphaNum("letter")
  p.alphaNum(["letter"])
  check p.hasErrors == false
  p.alphaNum("withDash")
  p.alphaNum("ja")
  check p.hasErrors
  check p.errors["withDash"][0] == "The withDash may only contain letters and numbers."
  check p.errors["ja"][0] == "The ja may only contain letters and numbers."

block:
  let p = newParams()
  p["valid"] = Param(value:"a, b, c")
  p["dict"] = Param(value:"""{"a": "a", "b": "b"}""")
  p["kv"] = Param(value:"a=a, b=b")
  p["str"] = Param(value:"adaddadad")
  p["number"] = Param(value:"1313193")
  p.array("valid")
  p.array(["valid"])
  check p.hasErrors == false
  p.array("dict")
  p.array("kv")
  p.array("str")
  p.array("number")
  check p.hasErrors
  check p.errors["kv"][0] == "The kv must be an array."
  check p.errors["number"][0] == "The number must be an array."
  check p.errors["dict"][0] == "The dict must be an array."
  check p.errors["str"][0] == "The str must be an array."

block:
  let p = newParams()
  p["a"] = Param(value:"2020-01-02")
  p["b"] = Param(value:"2020-01-01")
  p["c"] = Param(value:"2020-01-03")
  p.before("a", "c", "yyyy-MM-dd")
  p.before("a", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check p.hasErrors == false
  p.before("a", "b", "yyyy-MM-dd")
  p.before("a", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check p.hasErrors
  check p.errors["a"][0] == "The a must be a date before 2020-01-01."
  check p.errors["a"][1] == "The a must be a date before 2020-01-01T00:00:00+00:00."

block:
  let p = newParams()
  p["base"] = Param(value:"2020-01-02")
  p["before"] = Param(value:"2020-01-01")
  p["after"] = Param(value:"2020-01-03")
  p["same"] = Param(value:"2020-01-02")
  p.beforeOrEqual("base", "after", "yyyy-MM-dd")
  p.beforeOrEqual("base", "same", "yyyy-MM-dd")
  p.beforeOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check p.hasErrors == false
  p.beforeOrEqual("base", "before", "yyyy-MM-dd")
  p.beforeOrEqual("base", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be a date before or equal to 2020-01-01."
  check p.errors["base"][1] == "The base must be a date before or equal to 2020-01-01T00:00:00+00:00."


block:
  let p = newParams()
  p["num"] = Param(value:"2")
  p["str"] = Param(value:"aa")
  p["arr"] = Param(value:"a, b")
  p["file"] = Param(value:"a".repeat(2000), ext:"jpg")
  p.betweenNum("num", 1, 3)
  p.betweenNum("num", 1.1, 3.3)
  p.betweenStr("str", 1, 3)
  p.betweenArr("arr", 1, 3)
  p.betweenFile("file", 1, 3)
  check p.hasErrors == false
  p.betweenNum("num", 3, 4)
  p.betweenStr("str", 3, 4)
  p.betweenArr("arr", 3, 4)
  p.betweenFile("file", 3, 4)
  check p.hasErrors
  check p.errors["num"][0] == "The num must be between 3 and 4."
  check p.errors["str"][0] == "The str must be between 3 and 4 characters."
  check p.errors["arr"][0] == "The arr must have between 3 and 4 items."
  check p.errors["file"][0] == "The file must be between 3 and 4 kilobytes."

block:
  let p = newParams()
  p["true"] = Param(value:"true")
  p["a"] = Param(value:"a")
  p.boolean("true")
  p.boolean(["true"])
  check p.hasErrors == false
  p.boolean("a")
  check p.hasErrors
  check p.errors["a"][0] == "The a field must be true or false."

block:
  let p = newParams()
  p["password"] = Param(value:"valid")
  p["password_confirmation"] = Param(value:"valid")
  p.confirmed("password")
  check p.hasErrors == false
  p["password_confirmation"] = Param(value:"invalid")
  p.confirmed("password")
  check p.hasErrors
  check p.errors["password_confirmation"][0] == "The password confirmation does not match."

block:
  let p = newParams()
  p["valid"] = Param(value:"2020-01-01")
  p["invalid"] = Param(value:"aaa")
  p.date("valid", "yyyy-MM-dd")
  check p.hasErrors == false
  p.date("invalid", "yyyy-MM-dd")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid is not a valid date."

block:
  let p = newParams()
  p["valid_date"] = Param(value:"2020-01-01")
  p["invalid_date"] = Param(value:"a")
  p["valid_timestamp"] = Param(value:"1577880000")
  p["invalid_timestamp"] = Param(value:"1577980000")
  p.dateEquals("valid_date", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
  p.dateEquals("valid_timestamp", "2020-01-01".parse("yyyy-MM-dd"))
  check p.hasErrors == false
  p.dateEquals("invalid_date", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
  p.dateEquals("invalid_timestamp", "2020-01-01".parse("yyyy-MM-dd"))
  check p.hasErrors
  check p.errors["invalid_date"][0] == "The invalid_date must be a date equal to 2020-01-01."
  check p.errors["invalid_timestamp"][0] == "The invalid_timestamp must be a date equal to 2020-01-01."


block:
  let p = newParams()
  p["base"] = Param(value:"a")
  p["valid"] = Param(value:"b")
  p["invalid"] = Param(value:"a")
  p.different("base", "valid")
  check p.hasErrors == false
  p.different("base", "invalid")
  check p.hasErrors
  check p.errors["base"][0] == "The base and invalid must be different."


block:
  let p = newParams()
  p["valid"] = Param(value:"11")
  p["invalid"] = Param(value:"111")
  p.digits("valid", 2)
  check p.hasErrors == false
  p.digits("invalid", 2)
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be 2 digits."


block:
  let p = newParams()
  p["valid"] = Param(value:"11")
  p["invalid"] = Param(value:"111")
  p.digitsBetween("valid", 1, 3)
  check p.hasErrors == false
  p.digitsBetween("invalid", 4, 5)
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be between 4 and 5 digits."


block:
  let p = newParams()
  p["valid"] = Param(value:"a, b, c")
  p["invalid"] = Param(value:"a, b, b")
  p.distinctArr("valid")
  check p.hasErrors == false
  p.distinctArr("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid field has a duplicate value."


block:
  let p = newParams()
  p["a"] = Param(value:"domain.com")
  p["b"] = Param(value:"[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]")
  p["c"] = Param(value:"[2001:0db8:bd05:01d2:288a::1fc0:0001:10ee]")
  p.domain("a")
  p.domain("b")
  p.domain(["a", "b"])
  check p.hasErrors == false

  p.domain("c")
  check p.hasErrors
  check p.errors["c"][0] == "The c must be a valid domain."


block:
  let p = newParams()
  p["valid"] = Param(value:"email@domain.com")
  p["invalid"] = Param(value:"Abc.@example.com")
  p.email("valid")
  p.email(["valid"])
  check p.hasErrors == false
  p.email("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be a valid email address."


block:
  let p = newParams()
  p["item"] = Param(value:"abcdefg")
  p.endsWith("item", "fg")
  check p.hasErrors == false
  p.endsWith("item", "gh")
  check p.hasErrors
  check p.errors["item"][0] == "The item must be end with one of following gh."


block:
  let p = newParams()
  p["valid"] = Param(value:"a", ext:"jpg")
  p["invalid"] = Param(value:"a")
  p.file("valid")
  p.file(["valid"])
  check p.hasErrors == false
  p.file("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be a file."


block:
  let p = newParams()
  p["valid"] = Param(value:"a")
  p["invalid"] = Param(value:"")
  p.filled("valid")
  p.filled(["valid"])
  check p.hasErrors == false
  p.filled("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid field must have a value."


block:
  let p = newParams()
  p["base"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  p.gtNum("base", "smaller")
  check p.hasErrors == false
  p.gtNum("base", "bigger")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be greater than bigger."

block:
  let p = newParams()
  p["base"] = Param(value:"ab", ext:"jpg")
  p["smaller"] = Param(value:"a", ext:"jpg")
  p["bigger"] = Param(value:"abc", ext:"jpg")
  p.gtFile("base", "smaller")
  check p.hasErrors == false
  p.gtFile("base", "bigger")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be greater than 0.0029296875 kilobytes."

block:
  let p = newParams()
  p["base"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  p.gtStr("base", "smaller")
  check p.hasErrors == false
  p.gtStr("base", "bigger")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be greater than bigger characters."

block:
  let p = newParams()
  p["base"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  p.gtArr("base", "smaller")
  check p.hasErrors == false
  p.gtArr("base", "bigger")
  check p.hasErrors
  check p.errors["base"][0] == "The base must have more than bigger items."


block:
  let p = newParams()
  p["base"] = Param(value:"2")
  p["same"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  p.gteNum("base", "smaller")
  p.gteNum("base", "same")
  check p.hasErrors == false
  p.gteNum("base", "bigger")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be greater than or equal bigger."

block:
  let p = newParams()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["same"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["smaller"] = Param(value:"a".repeat(1*1024), ext:"jpg")
  p["bigger"] = Param(value:"a".repeat(3*1024), ext:"jpg")
  p.gteFile("base", "smaller")
  p.gteFile("base", "same")
  check p.hasErrors == false
  p.gteFile("base", "bigger")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be greater than or equal 3 kilobytes."

block:
  let p = newParams()
  p["base"] = Param(value:"ab")
  p["same"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  p.gteStr("base", "smaller")
  p.gteStr("base", "same")
  check p.hasErrors == false
  p.gteStr("base", "bigger")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be greater than or equal bigger characters."

block:
  let p = newParams()
  p["base"] = Param(value:"a, b")
  p["same"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  p.gteArr("base", "smaller")
  p.gteArr("base", "same")
  check p.hasErrors == false
  p.gteArr("base", "bigger")
  check p.hasErrors
  check p.errors["base"][0] == "The base must have bigger items or more."


block:
  let p = newParams()
  p["valid"] = Param(ext:"jpg")
  p["invalid"] = Param(ext:"nim")
  p.image("valid")
  p.image(["valid"])
  check p.hasErrors == false
  p.image("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be an image."


block:
  let p = newParams()
  p["valid"] = Param(value:"a")
  p["invalid"] = Param(value:"c")
  p.in("valid", ["a", "b"])
  check p.hasErrors == false
  p.in("invalid", ["a", "b"])
  check p.hasErrors
  check p.errors["invalid"][0] == "The selected invalid is invalid."


block:
  let p = newParams()
  p["base"] = Param(value:"a")
  p["valid"] = Param(value:"a, b, c")
  p["invalid"] = Param(value:"b, c")
  p.inArray("base", "valid")
  check p.hasErrors == false
  p.inArray("base", "invalid")
  check p.hasErrors
  check p.errors["base"][0] == "The base field does not exist in invalid."

block:
  let p = newParams()
  p["valid"] = Param(value:"1")
  p["invalid"] = Param(value:"a")
  p.integer("valid")
  p.integer(["valid"])
  check p.hasErrors == false
  p.integer("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be an integer."


block:
  let p = newParams()
  p["valid"] = Param(value:"""{"key": "value"}""")
  p["invalid"] = Param(value:"a")
  p.json("valid")
  p.json(["valid"])
  check p.hasErrors == false
  p.json("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be a valid JSON string."


block:
  let p = newParams()
  p["base"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  p.ltNum("base", "bigger")
  check p.hasErrors == false
  p.ltNum("base", "smaller")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be less than smaller."

block:
  let p = newParams()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["smaller"] = Param(value:"a".repeat(1*1024), ext:"jpg")
  p["bigger"] = Param(value:"a".repeat(3*1024), ext:"jpg")
  p.ltFile("base", "bigger")
  check p.hasErrors == false
  p.ltFile("base", "smaller")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be less than 1.0 kilobytes."

block:
  let p = newParams()
  p["base"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  p.ltStr("base", "bigger")
  check p.hasErrors == false
  p.ltStr("base", "smaller")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be less than smaller characters."

block:
  let p = newParams()
  p["base"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  p.ltArr("base", "bigger")
  check p.hasErrors == false
  p.ltArr("base", "smaller")
  check p.hasErrors
  check p.errors["base"][0] == "The base must have less than smaller items."


block:
  let p = newParams()
  p["base"] = Param(value:"2")
  p["same"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  p.lteNum("base", "bigger")
  p.lteNum("base", "same")
  check p.hasErrors == false
  p.lteNum("base", "smaller")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be less than or equal smaller."

block:
  let p = newParams()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["same"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["smaller"] = Param(value:"a".repeat(1*1024), ext:"jpg")
  p["bigger"] = Param(value:"a".repeat(3*1024), ext:"jpg")
  p.lteFile("base", "bigger")
  p.lteFile("base", "same")
  check p.hasErrors == false
  p.lteFile("base", "smaller")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be less than or equal 1 kilobytes."

block:
  let p = newParams()
  p["base"] = Param(value:"ab")
  p["same"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  p.lteStr("base", "bigger")
  p.lteStr("base", "same")
  check p.hasErrors == false
  p.lteStr("base", "smaller")
  check p.hasErrors
  check p.errors["base"][0] == "The base must be less than or equal smaller characters."

block:
  let p = newParams()
  p["base"] = Param(value:"a, b")
  p["same"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  p.lteArr("base", "bigger")
  p.lteArr("base", "same")
  check p.hasErrors == false
  p.lteArr("base", "smaller")
  check p.hasErrors
  check p.errors["base"][0] == "The base must not have more than smaller items."


block:
  let p = newParams()
  p["base"] = Param(value:"2")
  p.maxNum("base", 3)
  p.maxNum("base", 2)
  check p.hasErrors == false
  p.maxNum("base", 1)
  check p.hasErrors
  check p.errors["base"][0] == "The base may not be greater than 1."

block:
  let p = newParams()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p.maxFile("base", 3)
  p.maxFile("base", 2)
  check p.hasErrors == false
  p.maxFile("base", 1)
  check p.hasErrors
  check p.errors["base"][0] == "The base may not be greater than 1 kilobytes."

block:
  let p = newParams()
  p["base"] = Param(value:"ab")
  p.maxStr("base", 3)
  p.maxStr("base", 2)
  check p.hasErrors == false
  p.maxStr("base", 1)
  check p.hasErrors
  check p.errors["base"][0] == "The base may not be greater than 1 characters."

block:
  let p = newParams()
  p["base"] = Param(value:"a, b")
  p.maxArr("base", 3)
  p.maxArr("base", 2)
  check p.hasErrors == false
  p.maxArr("base", 1)
  check p.hasErrors
  check p.errors["base"][0] == "The base may not have more than 1 items."


block:
  let p = newParams()
  p["valid"] = Param(value:"a", ext:"jpg")
  p["invalid"] = Param(value:"a", ext:"mp4")
  p.mimes("valid", ["jpg", "png", "gif"])
  check p.hasErrors == false
  p.mimes("invalid", ["jpg", "png", "gif"])
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be a file of type: [\"jpg\", \"png\", \"gif\"]."


block:
  let p = newParams()
  p["base"] = Param(value:"2")
  p.minNum("base", 1)
  p.minNum("base", 2)
  check p.hasErrors == false
  p.minNum("base", 3)
  check p.hasErrors
  check p.errors["base"][0] == "The base must be at least 3."

block:
  let p = newParams()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p.minFile("base", 1)
  p.minFile("base", 2)
  check p.hasErrors == false
  p.minFile("base", 3)
  check p.hasErrors
  check p.errors["base"][0] == "The base must be at least 3 kilobytes."

block:
  let p = newParams()
  p["base"] = Param(value:"ab")
  p.minStr("base", 1)
  p.minStr("base", 2)
  check p.hasErrors == false
  p.minStr("base", 3)
  check p.hasErrors
  check p.errors["base"][0] == "The base must be at least 3 characters."

block:
  let p = newParams()
  p["base"] = Param(value:"a, b")
  p.minArr("base", 1)
  p.minArr("base", 2)
  check p.hasErrors == false
  p.minArr("base", 3)
  check p.hasErrors
  check p.errors["base"][0] == "The base must have at least 3 items."


block:
  let p = newParams()
  p["valid"] = Param(value:"a")
  p["invalid"] = Param(value:"b")
  p.notIn("valid", ["b", "c"])
  check p.hasErrors == false
  p.notIn("invalid", ["b", "c"])
  check p.hasErrors
  check p.errors["invalid"][0] == "The selected invalid is invalid."


block:
  let p = newParams()
  p["base"] = Param(value:"abc")
  p.notRegex("base", re"\d")
  check p.hasErrors == false
  p.notRegex("base", re"\w")
  check p.hasErrors
  check p.errors["base"][0] == "The base format is invalid."


block:
  let p = newParams()
  p["valid"] = Param(value:"-1.23")
  p["invalid"] = Param(value:"abc")
  p.numeric("valid")
  p.numeric(["valid"])
  check p.hasErrors == false
  p.numeric("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be a number."



block:
  let p = newParams()
  p["valid"] = Param(value:"a")
  p.present("valid")
  p.present(["valid"])
  check p.hasErrors == false
  p.present("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid field must be present."


block:
  let p = newParams()
  p["base"] = Param(value:"abc")
  p.regex("base", re"\w")
  check p.hasErrors == false
  p.regex("base", re"\d")
  check p.hasErrors
  check p.errors["base"][0] == "The base format is invalid."


block:
  let p = newParams()
  p["other"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  p.requiredIf("valid", "other", ["123"])
  p.requiredIf("valid", "other", ["abc"])
  check p.hasErrors == false
  p.requiredIf("invalid1", "other", ["123"])
  p.requiredIf("invalid2", "other", ["123"])
  check p.hasErrors
  check p.errors["invalid1"][0] == "The invalid1 field is required when other is 123."
  check p.errors["invalid2"][0] == "The invalid2 field is required when other is 123."


block:
  let p = newParams()
  p["other"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  p.requiredUnless("valid", "other", ["123"])
  p.requiredUnless("valid", "other", ["abc"])
  check p.hasErrors == false
  p.requiredUnless("invalid1", "other", ["abc"])
  p.requiredUnless("invalid2", "other", ["abc"])
  check p.hasErrors
  check p.errors["invalid1"][0] == "The invalid1 field is required unless other is in [\"abc\"]."
  check p.errors["invalid2"][0] == "The invalid2 field is required unless other is in [\"abc\"]."


block:
  let p = newParams()
  p["other"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  p.requiredWith("valid", ["a"])
  p.requiredWith("valid", ["other"])
  check p.hasErrors == false
  p.requiredWith("invalid1", ["other"])
  p.requiredWith("invalid2", ["other"])
  check p.hasErrors
  check p.errors["invalid1"][0] == "The invalid1 field is required when [\"other\"] is present."
  check p.errors["invalid2"][0] == "The invalid2 field is required when [\"other\"] is present."



block:
  let p = newParams()
  p["other1"] = Param(value:"123")
  p["other2"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  p.requiredWithAll("valid", ["other1", "other2"])
  p.requiredWithAll("invalid1", ["notExists"])
  check p.hasErrors == false
  p.requiredWithAll("invalid1", ["other1", "other2"])
  p.requiredWithAll("invalid2", ["other1", "other2"])
  check p.hasErrors
  check p.errors["invalid1"][0] == "The invalid1 field is required when [\"other1\", \"other2\"] are present."
  check p.errors["invalid2"][0] == "The invalid2 field is required when [\"other1\", \"other2\"] are present."



block:
  let p = newParams()
  p["other1"] = Param(value:"123")
  p["other2"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  p.requiredWithout("valid", ["other1", "other2"])
  p.requiredWithout("valid", ["notExists"])
  check p.hasErrors == false
  p.requiredWithout("invalid1", ["other1", "aaa"])
  p.requiredWithout("invalid2", ["other1", "aaa"])
  check p.hasErrors
  check p.errors["invalid1"][0] == "The invalid1 field is required when [\"other1\", \"aaa\"] is not present."
  check p.errors["invalid2"][0] == "The invalid2 field is required when [\"other1\", \"aaa\"] is not present."



block:
  let p = newParams()
  p["valid"] = Param(value:"abc")
  p["other"] = Param(value:"123")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  p.requiredWithoutAll("valid", ["aaa", "bbb"])
  p.requiredWithoutAll("invalid1", ["other"])
  check p.hasErrors == false
  p.requiredWithoutAll("invalid1", ["aaa", "bbb"])
  p.requiredWithoutAll("invalid2", ["aaa", "bbb"])
  check p.hasErrors
  check p.errors["invalid1"][0] == "The invalid1 field is required when none of [\"aaa\", \"bbb\"] are present."
  check p.errors["invalid2"][0] == "The invalid2 field is required when none of [\"aaa\", \"bbb\"] are present."


block:
  let p = newParams()
  p["a"] = Param(value:"a")
  p["b"] = Param(value:"a")
  p["c"] = Param(value:"c")
  p.same("a", "b")
  check p.hasErrors == false
  p.same("a", "c")
  check p.hasErrors
  check p.errors["a"][0] == "The a and c must match."

block:
  let p = newParams()
  p["num"] = Param(value:"2")
  p["file"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["str"] = Param(value:"ab")
  p["arr"] = Param(value:"a, b")
  p.sizeNum("num", 2)
  p.sizeFile("file", 2)
  p.sizeStr("str", 2)
  p.sizeArr("arr", 2)
  check p.hasErrors == false
  p.sizeNum("num", 1)
  p.sizeFile("file", 1)
  p.sizeStr("str", 1)
  p.sizeArr("arr", 1)
  check p.hasErrors
  check p.errors["num"][0] == "The num must be 1."
  check p.errors["file"][0] == "The file must be 1 kilobytes."
  check p.errors["str"][0] == "The str must be 1 characters."
  check p.errors["arr"][0] == "The arr must contain 1 items."


block:
  let p = newParams()
  p["base"] = Param(value:"abcde")
  p.startsWith("base", ["abc", "bcd"])
  check p.hasErrors == false
  p.startsWith("base", ["bcd", "cde"])
  check p.hasErrors
  check p.errors["base"][0] == "The base must be start with one of following [\"bcd\", \"cde\"]."

block:
  let p = newParams()
  p["validtimestamp"] = Param(value:"1577804400")
  p["invalidtimestamp"] = Param(value:"18446744073709551615")
  p["negative"] = Param(value:"-1")
  p.timestamp("validtimestamp")
  check p.hasErrors == false
  p.timestamp("negative")
  p.timestamp("invalidtimestamp")
  check p.errors["negative"][0] == "The negative is not a valid timestamp."
  check p.errors["invalidtimestamp"][0] == "The invalidtimestamp is not a valid timestamp."

block:
  let p = newParams()
  p["valid"] = Param(value:"https://google.com:8000/xxx/yyy/zzz?key=value")
  p["invalid"] = Param(value:"fnyuaAxmoiniancywcnsnmuaic")
  p.url("valid")
  p.url(["valid"])
  check p.hasErrors == false
  p.url("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid format is invalid."

block:
  let p = newParams()
  p["valid"] = Param(value:"a0a2a2d2-0b87-4a18-83f2-2529882be2de")
  p["invalid"] = Param(value:"iuajfassacds")
  p.uuid("valid")
  p.uuid(["valid"])
  check p.hasErrors == false
  p.uuid("invalid")
  check p.hasErrors
  check p.errors["invalid"][0] == "The invalid must be a valid UUID."
