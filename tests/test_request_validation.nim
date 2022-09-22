discard """
  cmd: "nim c -r $file"
"""

import unittest, times
include ../src/basolato/core/request
include ../src/basolato/request_validation

block:
  let p = Params.new()
  p["on"] = Param(value:"on")
  p["yes"] = Param(value:"yes")
  p["one"] = Param(value:"1")
  p["true"] = Param(value:"true")
  p["invalid"] = Param(value:"invalid")
  let v = RequestValidation.new(p)
  v.accepted("on")
  v.accepted("yes")
  v.accepted("one")
  v.accepted("true")
  v.accepted(["on", "yes", "one", "true"])
  check v.hasErrors == false

  v.accepted("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be accepted."

block:
  let p = Params.new()
  p["a"] = Param(value:"2020-01-02")
  p["b"] = Param(value:"2020-01-01")
  p["c"] = Param(value:"2020-01-03")
  let v = RequestValidation.new(p)
  v.after("a", "b", "yyyy-MM-dd")
  v.after("a", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasErrors == false
  v.after("a", "c", "yyyy-MM-dd")
  v.after("a", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasErrors
  check v.errors["a"][0] == "The a must be a date after 2020-01-03."
  check v.errors["a"][1] == "The a must be a date after 2020-01-03T00:00:00+00:00."

block:
  let p = Params.new()
  p["base"] = Param(value:"2020-01-02")
  p["before"] = Param(value:"2020-01-01")
  p["after"] = Param(value:"2020-01-03")
  p["same"] = Param(value:"2020-01-02")
  let v = RequestValidation.new(p)
  v.afterOrEqual("base", "before", "yyyy-MM-dd")
  v.afterOrEqual("base", "same", "yyyy-MM-dd")
  v.afterOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasErrors == false
  v.afterOrEqual("base", "after", "yyyy-MM-dd")
  v.afterOrEqual("base", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be a date after or equal to 2020-01-03."
  check v.errors["base"][1] == "The base must be a date after or equal to 2020-01-03T00:00:00+00:00."

block:
  let p = Params.new()
  p["small"] = Param(value:"abcdefghijklmnopqrstuvwxyz")
  p["large"] = Param(value:"ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  p["number"] = Param(value:"1234567890")
  p["mark"] = Param(value:"!\"#$%&'()~=~|`{}*+<>?_@[]:;,./^-")
  p["ja"] = Param(value:"あいうえお")
  let v = RequestValidation.new(p)
  v.alpha("small")
  v.alpha("large")
  v.alpha(["small", "large"])
  check v.hasErrors == false
  v.alpha("number")
  v.alpha("mark")
  v.alpha("ja")
  check v.errors["number"][0] == "The number may only contain letters."
  check v.errors["mark"][0] == "The mark may only contain letters."
  check v.errors["ja"][0] == "The ja may only contain letters."

block:
  let p = Params.new()
  p["letter"] = Param(value:"abcABC012")
  p["withDash"] = Param(value:"abcABC012-_")
  p["ja"] = Param(value:"aA0あいうえお")
  let v = RequestValidation.new(p)
  v.alphaDash("letter")
  v.alphaDash("withDash")
  v.alphaDash(["letter", "withDash"])
  check v.hasErrors == false
  v.alphaDash("ja")
  check v.hasErrors
  check v.errors["ja"][0] == "The ja may only contain letters, numbers, dashes and underscores."


block:
  let p = Params.new()
  p["letter"] = Param(value:"abcABC012")
  p["withDash"] = Param(value:"abcABC012-_")
  p["ja"] = Param(value:"aA0あいうえお")
  let v = RequestValidation.new(p)
  v.alphaNum("letter")
  v.alphaNum(["letter"])
  check v.hasErrors == false
  v.alphaNum("withDash")
  v.alphaNum("ja")
  check v.hasErrors
  check v.errors["withDash"][0] == "The withDash may only contain letters and numbers."
  check v.errors["ja"][0] == "The ja may only contain letters and numbers."

block:
  let p = Params.new()
  p["valid"] = Param(value:"a, b, c")
  p["dict"] = Param(value:"""{"a": "a", "b": "b"}""")
  p["kv"] = Param(value:"a=a, b=b")
  p["str"] = Param(value:"adaddadad")
  p["number"] = Param(value:"1313193")
  let v = RequestValidation.new(p)
  v.array("valid")
  v.array(["valid"])
  check v.hasErrors == false
  v.array("dict")
  v.array("kv")
  v.array("str")
  v.array("number")
  check v.hasErrors
  check v.errors["kv"][0] == "The kv must be an array."
  check v.errors["number"][0] == "The number must be an array."
  check v.errors["dict"][0] == "The dict must be an array."
  check v.errors["str"][0] == "The str must be an array."

block:
  let p = Params.new()
  p["a"] = Param(value:"2020-01-02")
  p["b"] = Param(value:"2020-01-01")
  p["c"] = Param(value:"2020-01-03")
  let v = RequestValidation.new(p)
  v.before("a", "c", "yyyy-MM-dd")
  v.before("a", "2020-01-03".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasErrors == false
  v.before("a", "b", "yyyy-MM-dd")
  v.before("a", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasErrors
  check v.errors["a"][0] == "The a must be a date before 2020-01-01."
  check v.errors["a"][1] == "The a must be a date before 2020-01-01T00:00:00+00:00."

block:
  let p = Params.new()
  p["base"] = Param(value:"2020-01-02")
  p["before"] = Param(value:"2020-01-01")
  p["after"] = Param(value:"2020-01-03")
  p["same"] = Param(value:"2020-01-02")
  let v = RequestValidation.new(p)
  v.beforeOrEqual("base", "after", "yyyy-MM-dd")
  v.beforeOrEqual("base", "same", "yyyy-MM-dd")
  v.beforeOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasErrors == false
  v.beforeOrEqual("base", "before", "yyyy-MM-dd")
  v.beforeOrEqual("base", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be a date before or equal to 2020-01-01."
  check v.errors["base"][1] == "The base must be a date before or equal to 2020-01-01T00:00:00+00:00."


block:
  let p = Params.new()
  p["num"] = Param(value:"2")
  p["str"] = Param(value:"aa")
  p["arr"] = Param(value:"a, b")
  p["file"] = Param(value:"a".repeat(2000), ext:"jpg")
  let v = RequestValidation.new(p)
  v.betweenNum("num", 1, 3)
  v.betweenNum("num", 1.1, 3.3)
  v.betweenStr("str", 1, 3)
  v.betweenArr("arr", 1, 3)
  v.betweenFile("file", 1, 3)
  check v.hasErrors == false
  v.betweenNum("num", 3, 4)
  v.betweenStr("str", 3, 4)
  v.betweenArr("arr", 3, 4)
  v.betweenFile("file", 3, 4)
  check v.hasErrors
  check v.errors["num"][0] == "The num must be between 3 and 4."
  check v.errors["str"][0] == "The str must be between 3 and 4 characters."
  check v.errors["arr"][0] == "The arr must have between 3 and 4 items."
  check v.errors["file"][0] == "The file must be between 3 and 4 kilobytes."

block:
  let p = Params.new()
  p["true"] = Param(value:"true")
  p["a"] = Param(value:"a")
  let v = RequestValidation.new(p)
  v.boolean("true")
  v.boolean(["true"])
  check v.hasErrors == false
  v.boolean("a")
  check v.hasErrors
  check v.errors["a"][0] == "The a field must be true or false."

block:
  let p = Params.new()
  p["password"] = Param(value:"valid")
  p["password_confirmation"] = Param(value:"valid")
  var v = RequestValidation.new(p)
  v.confirmed("password")
  check v.hasErrors == false
  p["password_confirmation"] = Param(value:"invalid")
  v = RequestValidation.new(p)
  v.confirmed("password")
  check v.hasErrors
  check v.errors["password_confirmation"][0] == "The password confirmation does not match."

block:
  let p = Params.new()
  p["valid"] = Param(value:"2020-01-01")
  p["invalid"] = Param(value:"aaa")
  let v = RequestValidation.new(p)
  v.date("valid", "yyyy-MM-dd")
  check v.hasErrors == false
  v.date("invalid", "yyyy-MM-dd")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid is not a valid date."

block:
  let p = Params.new()
  p["valid_date"] = Param(value:"2020-01-01")
  p["invalid_date"] = Param(value:"a")
  p["valid_timestamp"] = Param(value:"1577880000")
  p["invalid_timestamp"] = Param(value:"1577980000")
  let v = RequestValidation.new(p)
  v.dateEquals("valid_date", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
  v.dateEquals("valid_timestamp", "2020-01-01".parse("yyyy-MM-dd"))
  check v.hasErrors == false
  v.dateEquals("invalid_date", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
  v.dateEquals("invalid_timestamp", "2020-01-01".parse("yyyy-MM-dd"))
  check v.hasErrors
  check v.errors["invalid_date"][0] == "The invalid_date must be a date equal to 2020-01-01."
  check v.errors["invalid_timestamp"][0] == "The invalid_timestamp must be a date equal to 2020-01-01."


block:
  let p = Params.new()
  p["base"] = Param(value:"a")
  p["valid"] = Param(value:"b")
  p["invalid"] = Param(value:"a")
  let v = RequestValidation.new(p)
  v.different("base", "valid")
  check v.hasErrors == false
  v.different("base", "invalid")
  check v.hasErrors
  check v.errors["base"][0] == "The base and invalid must be different."


block:
  let p = Params.new()
  p["valid"] = Param(value:"11")
  p["invalid"] = Param(value:"111")
  let v = RequestValidation.new(p)
  v.digits("valid", 2)
  check v.hasErrors == false
  v.digits("invalid", 2)
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be 2 digits."


block:
  let p = Params.new()
  p["valid"] = Param(value:"11")
  p["invalid"] = Param(value:"111")
  let v = RequestValidation.new(p)
  v.digitsBetween("valid", 1, 3)
  check v.hasErrors == false
  v.digitsBetween("invalid", 4, 5)
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be between 4 and 5 digits."


block:
  let p = Params.new()
  p["valid"] = Param(value:"a, b, c")
  p["invalid"] = Param(value:"a, b, b")
  let v = RequestValidation.new(p)
  v.distinctArr("valid")
  check v.hasErrors == false
  v.distinctArr("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid field has a duplicate value."


block:
  let p = Params.new()
  p["a"] = Param(value:"domain.com")
  p["b"] = Param(value:"[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]")
  p["c"] = Param(value:"[2001:0db8:bd05:01d2:288a::1fc0:0001:10ee]")
  let v = RequestValidation.new(p)
  v.domain("a")
  v.domain("b")
  v.domain(["a", "b"])
  check v.hasErrors == false

  v.domain("c")
  check v.hasErrors
  check v.errors["c"][0] == "The c must be a valid domain."


block:
  let p = Params.new()
  p["valid"] = Param(value:"email@domain.com")
  p["invalid"] = Param(value:"Abc.@example.com")
  let v = RequestValidation.new(p)
  v.email("valid")
  v.email(["valid"])
  check v.hasErrors == false
  v.email("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a valid email address."


block:
  let p = Params.new()
  p["item"] = Param(value:"abcdefg")
  let v = RequestValidation.new(p)
  v.endsWith("item", ["fg"])
  check v.hasErrors == false
  v.endsWith("item", ["gh"])
  check v.hasErrors
  check v.errors["item"][0] == "The item must be end with one of following [\"gh\"]."


block:
  let p = Params.new()
  p["valid"] = Param(value:"a", ext:"jpg")
  p["invalid"] = Param(value:"a")
  let v = RequestValidation.new(p)
  v.file("valid")
  v.file(["valid"])
  check v.hasErrors == false
  v.file("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a file."


block:
  let p = Params.new()
  p["valid"] = Param(value:"a")
  p["invalid"] = Param(value:"")
  let v = RequestValidation.new(p)
  v.filled("valid")
  v.filled(["valid"])
  check v.hasErrors == false
  v.filled("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid field must have a value."


block:
  let p = Params.new()
  p["base"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  let v = RequestValidation.new(p)
  v.gtNum("base", "smaller")
  check v.hasErrors == false
  v.gtNum("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than bigger."

block:
  let p = Params.new()
  p["base"] = Param(value:"ab", ext:"jpg")
  p["smaller"] = Param(value:"a", ext:"jpg")
  p["bigger"] = Param(value:"abc", ext:"jpg")
  let v = RequestValidation.new(p)
  v.gtFile("base", "smaller")
  check v.hasErrors == false
  v.gtFile("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than 0.0029296875 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  let v = RequestValidation.new(p)
  v.gtStr("base", "smaller")
  check v.hasErrors == false
  v.gtStr("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than bigger characters."

block:
  let p = Params.new()
  p["base"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  let v = RequestValidation.new(p)
  v.gtArr("base", "smaller")
  check v.hasErrors == false
  v.gtArr("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must have more than bigger items."


block:
  let p = Params.new()
  p["base"] = Param(value:"2")
  p["same"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  let v = RequestValidation.new(p)
  v.gteNum("base", "smaller")
  v.gteNum("base", "same")
  check v.hasErrors == false
  v.gteNum("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than or equal bigger."

block:
  let p = Params.new()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["same"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["smaller"] = Param(value:"a".repeat(1*1024), ext:"jpg")
  p["bigger"] = Param(value:"a".repeat(3*1024), ext:"jpg")
  let v = RequestValidation.new(p)
  v.gteFile("base", "smaller")
  v.gteFile("base", "same")
  check v.hasErrors == false
  v.gteFile("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than or equal 3 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param(value:"ab")
  p["same"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  let v = RequestValidation.new(p)
  v.gteStr("base", "smaller")
  v.gteStr("base", "same")
  check v.hasErrors == false
  v.gteStr("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than or equal bigger characters."

block:
  let p = Params.new()
  p["base"] = Param(value:"a, b")
  p["same"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  let v = RequestValidation.new(p)
  v.gteArr("base", "smaller")
  v.gteArr("base", "same")
  check v.hasErrors == false
  v.gteArr("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must have bigger items or more."


block:
  let p = Params.new()
  p["valid"] = Param(ext:"jpg")
  p["invalid"] = Param(ext:"nim")
  let v = RequestValidation.new(p)
  v.image("valid")
  v.image(["valid"])
  check v.hasErrors == false
  v.image("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be an image."


block:
  let p = Params.new()
  p["valid"] = Param(value:"a")
  p["invalid"] = Param(value:"c")
  let v = RequestValidation.new(p)
  v.in("valid", ["a", "b"])
  check v.hasErrors == false
  v.in("invalid", ["a", "b"])
  check v.hasErrors
  check v.errors["invalid"][0] == "The selected invalid is invalid."


block:
  let p = Params.new()
  p["base"] = Param(value:"a")
  p["valid"] = Param(value:"a, b, c")
  p["invalid"] = Param(value:"b, c")
  let v = RequestValidation.new(p)
  v.inArray("base", "valid")
  check v.hasErrors == false
  v.inArray("base", "invalid")
  check v.hasErrors
  check v.errors["base"][0] == "The base field does not exist in invalid."

block:
  let p = Params.new()
  p["valid"] = Param(value:"1")
  p["invalid"] = Param(value:"a")
  let v = RequestValidation.new(p)
  v.integer("valid")
  v.integer(["valid"])
  check v.hasErrors == false
  v.integer("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be an integer."


block:
  let p = Params.new()
  p["valid"] = Param(value:"""{"key": "value"}""")
  p["invalid"] = Param(value:"a")
  let v = RequestValidation.new(p)
  v.json("valid")
  v.json(["valid"])
  check v.hasErrors == false
  v.json("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a valid JSON string."


block:
  let p = Params.new()
  p["base"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  let v = RequestValidation.new(p)
  v.ltNum("base", "bigger")
  check v.hasErrors == false
  v.ltNum("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than smaller."

block:
  let p = Params.new()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["smaller"] = Param(value:"a".repeat(1*1024), ext:"jpg")
  p["bigger"] = Param(value:"a".repeat(3*1024), ext:"jpg")
  let v = RequestValidation.new(p)
  v.ltFile("base", "bigger")
  check v.hasErrors == false
  v.ltFile("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than 1.0 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  let v = RequestValidation.new(p)
  v.ltStr("base", "bigger")
  check v.hasErrors == false
  v.ltStr("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than smaller characters."

block:
  let p = Params.new()
  p["base"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  let v = RequestValidation.new(p)
  v.ltArr("base", "bigger")
  check v.hasErrors == false
  v.ltArr("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must have less than smaller items."


block:
  let p = Params.new()
  p["base"] = Param(value:"2")
  p["same"] = Param(value:"2")
  p["smaller"] = Param(value:"1")
  p["bigger"] = Param(value:"3")
  let v = RequestValidation.new(p)
  v.lteNum("base", "bigger")
  v.lteNum("base", "same")
  check v.hasErrors == false
  v.lteNum("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than or equal smaller."

block:
  let p = Params.new()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["same"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["smaller"] = Param(value:"a".repeat(1*1024), ext:"jpg")
  p["bigger"] = Param(value:"a".repeat(3*1024), ext:"jpg")
  let v = RequestValidation.new(p)
  v.lteFile("base", "bigger")
  v.lteFile("base", "same")
  check v.hasErrors == false
  v.lteFile("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than or equal 1 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param(value:"ab")
  p["same"] = Param(value:"ab")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"abc")
  let v = RequestValidation.new(p)
  v.lteStr("base", "bigger")
  v.lteStr("base", "same")
  check v.hasErrors == false
  v.lteStr("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than or equal smaller characters."

block:
  let p = Params.new()
  p["base"] = Param(value:"a, b")
  p["same"] = Param(value:"a, b")
  p["smaller"] = Param(value:"a")
  p["bigger"] = Param(value:"a, b, c")
  let v = RequestValidation.new(p)
  v.lteArr("base", "bigger")
  v.lteArr("base", "same")
  check v.hasErrors == false
  v.lteArr("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must not have more than smaller items."


block:
  let p = Params.new()
  p["base"] = Param(value:"2")
  let v = RequestValidation.new(p)
  v.maxNum("base", 3)
  v.maxNum("base", 2)
  check v.hasErrors == false
  v.maxNum("base", 1)
  check v.hasErrors
  check v.errors["base"][0] == "The base may not be greater than 1."

block:
  let p = Params.new()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  let v = RequestValidation.new(p)
  v.maxFile("base", 3)
  v.maxFile("base", 2)
  check v.hasErrors == false
  v.maxFile("base", 1)
  check v.hasErrors
  check v.errors["base"][0] == "The base may not be greater than 1 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param(value:"ab")
  let v = RequestValidation.new(p)
  v.maxStr("base", 3)
  v.maxStr("base", 2)
  check v.hasErrors == false
  v.maxStr("base", 1)
  check v.hasErrors
  check v.errors["base"][0] == "The base may not be greater than 1 characters."

block:
  let p = Params.new()
  p["base"] = Param(value:"a, b")
  let v = RequestValidation.new(p)
  v.maxArr("base", 3)
  v.maxArr("base", 2)
  check v.hasErrors == false
  v.maxArr("base", 1)
  check v.hasErrors
  check v.errors["base"][0] == "The base may not have more than 1 items."


block:
  let p = Params.new()
  p["valid"] = Param(value:"a", ext:"jpg")
  p["invalid"] = Param(value:"a", ext:"mp4")
  let v = RequestValidation.new(p)
  v.mimes("valid", ["jpg", "png", "gif"])
  check v.hasErrors == false
  v.mimes("invalid", ["jpg", "png", "gif"])
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a file of type: [\"jpg\", \"png\", \"gif\"]."


block:
  let p = Params.new()
  p["base"] = Param(value:"2")
  let v = RequestValidation.new(p)
  v.minNum("base", 1)
  v.minNum("base", 2)
  check v.hasErrors == false
  v.minNum("base", 3)
  check v.hasErrors
  check v.errors["base"][0] == "The base must be at least 3."

block:
  let p = Params.new()
  p["base"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  let v = RequestValidation.new(p)
  v.minFile("base", 1)
  v.minFile("base", 2)
  check v.hasErrors == false
  v.minFile("base", 3)
  check v.hasErrors
  check v.errors["base"][0] == "The base must be at least 3 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param(value:"ab")
  let v = RequestValidation.new(p)
  v.minStr("base", 1)
  v.minStr("base", 2)
  check v.hasErrors == false
  v.minStr("base", 3)
  check v.hasErrors
  check v.errors["base"][0] == "The base must be at least 3 characters."

block:
  let p = Params.new()
  p["base"] = Param(value:"a, b")
  let v = RequestValidation.new(p)
  v.minArr("base", 1)
  v.minArr("base", 2)
  check v.hasErrors == false
  v.minArr("base", 3)
  check v.hasErrors
  check v.errors["base"][0] == "The base must have at least 3 items."


block:
  let p = Params.new()
  p["valid"] = Param(value:"a")
  p["invalid"] = Param(value:"b")
  let v = RequestValidation.new(p)
  v.notIn("valid", ["b", "c"])
  check v.hasErrors == false
  v.notIn("invalid", ["b", "c"])
  check v.hasErrors
  check v.errors["invalid"][0] == "The selected invalid is invalid."


block:
  let p = Params.new()
  p["base"] = Param(value:"abc")
  let v = RequestValidation.new(p)
  v.notRegex("base", re"\d")
  check v.hasErrors == false
  v.notRegex("base", re"\w")
  check v.hasErrors
  check v.errors["base"][0] == "The base format is invalid."


block:
  let p = Params.new()
  p["valid"] = Param(value:"-1.23")
  p["invalid"] = Param(value:"abc")
  let v = RequestValidation.new(p)
  v.numeric("valid")
  v.numeric(["valid"])
  check v.hasErrors == false
  v.numeric("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a number."



block:
  let p = Params.new()
  p["valid"] = Param(value:"a")
  let v = RequestValidation.new(p)
  v.present("valid")
  v.present(["valid"])
  check v.hasErrors == false
  v.present("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid field must be present."


block:
  let p = Params.new()
  p["base"] = Param(value:"abc")
  let v = RequestValidation.new(p)
  v.regex("base", re"\w")
  check v.hasErrors == false
  v.regex("base", re"\d")
  check v.hasErrors
  check v.errors["base"][0] == "The base format is invalid."

block:
  let p = Params.new()
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = RequestValidation.new(p)
  v.required("valid")
  check v.hasErrors == false
  v.required("invalid1")
  v.required("invalid2")
  check v.hasErrors
  check v.errors["invalid1"][0] == "The invalid1 field is required."
  check v.errors["invalid2"][0] == "The invalid2 field is required."

block:
  let p = Params.new()
  p["other"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = RequestValidation.new(p)
  v.requiredIf("valid", "other", ["123"])
  v.requiredIf("valid", "other", ["abc"])
  check v.hasErrors == false
  v.requiredIf("invalid1", "other", ["123"])
  v.requiredIf("invalid2", "other", ["123"])
  check v.hasErrors
  check v.errors["invalid1"][0] == "The invalid1 field is required when other is 123."
  check v.errors["invalid2"][0] == "The invalid2 field is required when other is 123."


block:
  let p = Params.new()
  p["other"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = RequestValidation.new(p)
  v.requiredUnless("valid", "other", ["123"])
  v.requiredUnless("valid", "other", ["abc"])
  check v.hasErrors == false
  v.requiredUnless("invalid1", "other", ["abc"])
  v.requiredUnless("invalid2", "other", ["abc"])
  check v.hasErrors
  check v.errors["invalid1"][0] == "The invalid1 field is required unless other is in [\"abc\"]."
  check v.errors["invalid2"][0] == "The invalid2 field is required unless other is in [\"abc\"]."


block:
  let p = Params.new()
  p["other"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = RequestValidation.new(p)
  v.requiredWith("valid", ["a"])
  v.requiredWith("valid", ["other"])
  check v.hasErrors == false
  v.requiredWith("invalid1", ["other"])
  v.requiredWith("invalid2", ["other"])
  check v.hasErrors
  check v.errors["invalid1"][0] == "The invalid1 field is required when [\"other\"] is present."
  check v.errors["invalid2"][0] == "The invalid2 field is required when [\"other\"] is present."


block:
  let p = Params.new()
  p["other1"] = Param(value:"123")
  p["other2"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = RequestValidation.new(p)
  v.requiredWithAll("valid", ["other1", "other2"])
  v.requiredWithAll("invalid1", ["notExists"])
  check v.hasErrors == false
  v.requiredWithAll("invalid1", ["other1", "other2"])
  v.requiredWithAll("invalid2", ["other1", "other2"])
  check v.hasErrors
  check v.errors["invalid1"][0] == "The invalid1 field is required when [\"other1\", \"other2\"] are present."
  check v.errors["invalid2"][0] == "The invalid2 field is required when [\"other1\", \"other2\"] are present."


block:
  let p = Params.new()
  p["other1"] = Param(value:"123")
  p["other2"] = Param(value:"123")
  p["valid"] = Param(value:"abc")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = RequestValidation.new(p)
  v.requiredWithout("valid", ["other1", "other2"])
  v.requiredWithout("valid", ["notExists"])
  check v.hasErrors == false
  v.requiredWithout("invalid1", ["other1", "aaa"])
  v.requiredWithout("invalid2", ["other1", "aaa"])
  check v.hasErrors
  check v.errors["invalid1"][0] == "The invalid1 field is required when [\"other1\", \"aaa\"] is not present."
  check v.errors["invalid2"][0] == "The invalid2 field is required when [\"other1\", \"aaa\"] is not present."


block:
  let p = Params.new()
  p["valid"] = Param(value:"abc")
  p["other"] = Param(value:"123")
  p["invalid1"] = Param(value:"")
  p["invalid2"] = Param(value:"null")
  let v = RequestValidation.new(p)
  v.requiredWithoutAll("valid", ["aaa", "bbb"])
  v.requiredWithoutAll("invalid1", ["other"])
  check v.hasErrors == false
  v.requiredWithoutAll("invalid1", ["aaa", "bbb"])
  v.requiredWithoutAll("invalid2", ["aaa", "bbb"])
  check v.hasErrors
  check v.errors["invalid1"][0] == "The invalid1 field is required when none of [\"aaa\", \"bbb\"] are present."
  check v.errors["invalid2"][0] == "The invalid2 field is required when none of [\"aaa\", \"bbb\"] are present."


block:
  let p = Params.new()
  p["a"] = Param(value:"a")
  p["b"] = Param(value:"a")
  p["c"] = Param(value:"c")
  let v = RequestValidation.new(p)
  v.same("a", "b")
  check v.hasErrors == false
  v.same("a", "c")
  check v.hasErrors
  check v.errors["a"][0] == "The a and c must match."

block:
  let p = Params.new()
  p["num"] = Param(value:"2")
  p["file"] = Param(value:"a".repeat(2*1024), ext:"jpg")
  p["str"] = Param(value:"ab")
  p["arr"] = Param(value:"a, b")
  let v = RequestValidation.new(p)
  v.sizeNum("num", 2)
  v.sizeFile("file", 2)
  v.sizeStr("str", 2)
  v.sizeArr("arr", 2)
  check v.hasErrors == false
  v.sizeNum("num", 1)
  v.sizeFile("file", 1)
  v.sizeStr("str", 1)
  v.sizeArr("arr", 1)
  check v.hasErrors
  check v.errors["num"][0] == "The num must be 1."
  check v.errors["file"][0] == "The file must be 1 kilobytes."
  check v.errors["str"][0] == "The str must be 1 characters."
  check v.errors["arr"][0] == "The arr must contain 1 items."


block:
  let p = Params.new()
  p["base"] = Param(value:"abcde")
  let v = RequestValidation.new(p)
  v.startsWith("base", ["abc", "bcd"])
  check v.hasErrors == false
  v.startsWith("base", ["bcd", "cde"])
  check v.hasErrors
  check v.errors["base"][0] == "The base must be start with one of following [\"bcd\", \"cde\"]."

block:
  let p = Params.new()
  p["validtimestamp"] = Param(value:"1577804400")
  p["invalidtimestamp"] = Param(value:"18446744073709551615")
  p["negative"] = Param(value:"-1")
  let v = RequestValidation.new(p)
  v.timestamp("validtimestamp")
  check v.hasErrors == false
  v.timestamp("negative")
  v.timestamp("invalidtimestamp")
  check v.errors["negative"][0] == "The negative is not a valid timestamp."
  check v.errors["invalidtimestamp"][0] == "The invalidtimestamp is not a valid timestamp."

block:
  let p = Params.new()
  p["valid"] = Param(value:"https://google.com:8000/xxx/yyy/zzz?key=value")
  p["invalid"] = Param(value:"fnyuaAxmoiniancywcnsnmuaic")
  let v = RequestValidation.new(p)
  v.url("valid")
  v.url(["valid"])
  check v.hasErrors == false
  v.url("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid format is invalid."

block:
  let p = Params.new()
  p["valid"] = Param(value:"a0a2a2d2-0b87-4a18-83f2-2529882be2de")
  p["invalid"] = Param(value:"iuajfassacds")
  let v = RequestValidation.new(p)
  v.uuid("valid")
  v.uuid(["valid"])
  check v.hasErrors == false
  v.uuid("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a valid UUID."
