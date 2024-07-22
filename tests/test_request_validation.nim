discard """
  cmd: "nim c -d:test $file"
"""

import std/unittest
import std/asyncdispatch
import std/times
import std/tables
import std/strutils
import std/re
import ../src/basolato/core/libservers/std/request
import ../src/basolato/request_validation
import ../src/basolato/core/security/context
import ../src/basolato/core/params


block:
  let p = Params.new()
  p["on"] = Param.new("on")
  p["yes"] = Param.new("yes")
  p["one"] = Param.new("1")
  p["true"] = Param.new("true")
  p["invalid"] = Param.new("invalid")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["a"] = Param.new("2020-01-02")
  p["b"] = Param.new("2020-01-01")
  p["c"] = Param.new("2020-01-03")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["base"] = Param.new("2020-01-02")
  p["before"] = Param.new("2020-01-01")
  p["after"] = Param.new("2020-01-03")
  p["same"] = Param.new("2020-01-02")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["small"] = Param.new("abcdefghijklmnopqrstuvwxyz")
  p["large"] = Param.new("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  p["number"] = Param.new("1234567890")
  p["mark"] = Param.new("!\"#$%&'()~=~|`{}*+<>?_@[]:;,./^-")
  p["ja"] = Param.new("あいうえお")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["letter"] = Param.new("abcABC012")
  p["withDash"] = Param.new("abcABC012-_")
  p["ja"] = Param.new("aA0あいうえお")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.alphaDash("letter")
  v.alphaDash("withDash")
  v.alphaDash(["letter", "withDash"])
  check v.hasErrors == false
  v.alphaDash("ja")
  check v.hasErrors
  check v.errors["ja"][0] == "The ja may only contain letters, numbers, dashes and underscores."


block:
  let p = Params.new()
  p["letter"] = Param.new("abcABC012")
  p["withDash"] = Param.new("abcABC012-_")
  p["ja"] = Param.new("aA0あいうえお")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["valid"] = Param.new("a, b, c")
  p["dict"] = Param.new("""{"a": "a", "b": "b"}""")
  p["kv"] = Param.new("a=a, b=b")
  p["str"] = Param.new("adaddadad")
  p["number"] = Param.new("1313193")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["a"] = Param.new("2020-01-02")
  p["b"] = Param.new("2020-01-01")
  p["c"] = Param.new("2020-01-03")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["base"] = Param.new("2020-01-02")
  p["before"] = Param.new("2020-01-01")
  p["after"] = Param.new("2020-01-03")
  p["same"] = Param.new("2020-01-02")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["num"] = Param.new("2")
  p["str"] = Param.new("aa")
  p["arr"] = Param.new("a, b")
  p["file"] = Param.new("a".repeat(2000), "a", "jpg")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["true"] = Param.new("true")
  p["a"] = Param.new("a")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.boolean("true")
  v.boolean(["true"])
  check v.hasErrors == false
  v.boolean("a")
  check v.hasErrors
  check v.errors["a"][0] == "The a field must be true or false."

block:
  let p = Params.new()
  p["password"] = Param.new("valid")
  p["password_confirmation"] = Param.new("valid")
  let request = Request()
  var context = Context.new(request, p).waitFor()
  var v = RequestValidation.new(context)
  v.confirmed("password")
  check v.hasErrors == false
  p["password_confirmation"] = Param.new("invalid")
  context = Context.new(request, p).waitFor()
  v = RequestValidation.new(context)
  v.confirmed("password")
  check v.hasErrors
  check v.errors["password_confirmation"][0] == "The password confirmation does not match."

block:
  let p = Params.new()
  p["valid"] = Param.new("2020-01-01")
  p["invalid"] = Param.new("aaa")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.date("valid", "yyyy-MM-dd")
  check v.hasErrors == false
  v.date("invalid", "yyyy-MM-dd")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid is not a valid date."

block:
  let p = Params.new()
  p["valid_date"] = Param.new("2020-01-01")
  p["invalid_date"] = Param.new("a")
  p["valid_timestamp"] = Param.new("1577880000")
  p["invalid_timestamp"] = Param.new("1577980000")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["base"] = Param.new("a")
  p["valid"] = Param.new("b")
  p["invalid"] = Param.new("a")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.different("base", "valid")
  check v.hasErrors == false
  v.different("base", "invalid")
  check v.hasErrors
  check v.errors["base"][0] == "The base and invalid must be different."


block:
  let p = Params.new()
  p["valid"] = Param.new("11")
  p["invalid"] = Param.new("111")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.digits("valid", 2)
  check v.hasErrors == false
  v.digits("invalid", 2)
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be 2 digits."


block:
  let p = Params.new()
  p["valid"] = Param.new("11")
  p["invalid"] = Param.new("111")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.digitsBetween("valid", 1, 3)
  check v.hasErrors == false
  v.digitsBetween("invalid", 4, 5)
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be between 4 and 5 digits."


block:
  let p = Params.new()
  p["valid"] = Param.new("a, b, c")
  p["invalid"] = Param.new("a, b, b")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.distinctArr("valid")
  check v.hasErrors == false
  v.distinctArr("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid field has a duplicate value."


block:
  let p = Params.new()
  p["a"] = Param.new("domain.com")
  p["b"] = Param.new("[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]")
  p["c"] = Param.new("[2001:0db8:bd05:01d2:288a::1fc0:0001:10ee]")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.domain("a")
  v.domain("b")
  v.domain(["a", "b"])
  check v.hasErrors == false

  v.domain("c")
  check v.hasErrors
  check v.errors["c"][0] == "The c must be a valid domain."


block:
  let p = Params.new()
  p["valid"] = Param.new("email@domain.com")
  p["invalid"] = Param.new("Abc.@example.com")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.email("valid")
  v.email(["valid"])
  check v.hasErrors == false
  v.email("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a valid email address."


block:
  let p = Params.new()
  p["item"] = Param.new("abcdefg")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.endsWith("item", ["fg"])
  check v.hasErrors == false
  v.endsWith("item", ["gh"])
  check v.hasErrors
  check v.errors["item"][0] == "The item must be end with one of following [\"gh\"]."


block:
  let p = Params.new()
  p["valid"] = Param.new("a", "a", "jpg")
  p["invalid"] = Param.new("a")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.file("valid")
  v.file(["valid"])
  check v.hasErrors == false
  v.file("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a file."


block:
  let p = Params.new()
  p["valid"] = Param.new("a")
  p["invalid"] = Param.new("")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.filled("valid")
  v.filled(["valid"])
  check v.hasErrors == false
  v.filled("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid field must have a value."


block:
  let p = Params.new()
  p["base"] = Param.new("2")
  p["smaller"] = Param.new("1")
  p["bigger"] = Param.new("3")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.gtNum("base", "smaller")
  check v.hasErrors == false
  v.gtNum("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than bigger."

block:
  let p = Params.new()
  p["base"] = Param.new("ab", "base", "jpg")
  p["smaller"] = Param.new("a", "smaller", "jpg")
  p["bigger"] = Param.new("abc", "bigger", "jpg")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.gtFile("base", "smaller")
  check v.hasErrors == false
  v.gtFile("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than 0.0029296875 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param.new("ab")
  p["smaller"] = Param.new("a")
  p["bigger"] = Param.new("abc")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.gtStr("base", "smaller")
  check v.hasErrors == false
  v.gtStr("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than bigger characters."

block:
  let p = Params.new()
  p["base"] = Param.new("a, b")
  p["smaller"] = Param.new("a")
  p["bigger"] = Param.new("a, b, c")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.gtArr("base", "smaller")
  check v.hasErrors == false
  v.gtArr("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must have more than bigger items."


block:
  let p = Params.new()
  p["base"] = Param.new("2")
  p["same"] = Param.new("2")
  p["smaller"] = Param.new("1")
  p["bigger"] = Param.new("3")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.gteNum("base", "smaller")
  v.gteNum("base", "same")
  check v.hasErrors == false
  v.gteNum("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than or equal bigger."

block:
  let p = Params.new()
  p["base"] = Param.new("a".repeat(2*1024), "base", "jpg")
  p["same"] = Param.new("a".repeat(2*1024), "same", "jpg")
  p["smaller"] = Param.new("a".repeat(1*1024), "smaller", "jpg")
  p["bigger"] = Param.new("a".repeat(3*1024), "a", "jpg")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.gteFile("base", "smaller")
  v.gteFile("base", "same")
  check v.hasErrors == false
  v.gteFile("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than or equal 3 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param.new("ab")
  p["same"] = Param.new("ab")
  p["smaller"] = Param.new("a")
  p["bigger"] = Param.new("abc")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.gteStr("base", "smaller")
  v.gteStr("base", "same")
  check v.hasErrors == false
  v.gteStr("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be greater than or equal bigger characters."

block:
  let p = Params.new()
  p["base"] = Param.new("a, b")
  p["same"] = Param.new("a, b")
  p["smaller"] = Param.new("a")
  p["bigger"] = Param.new("a, b, c")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.gteArr("base", "smaller")
  v.gteArr("base", "same")
  check v.hasErrors == false
  v.gteArr("base", "bigger")
  check v.hasErrors
  check v.errors["base"][0] == "The base must have bigger items or more."


block:
  let p = Params.new()
  p["valid"] = Param.new("a", "valid", "jpg")
  p["invalid"] = Param.new("a", "invalid.nim", "nim")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.image("valid")
  v.image(["valid"])
  check v.hasErrors == false
  v.image("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be an image."


block:
  let p = Params.new()
  p["valid"] = Param.new("a")
  p["invalid"] = Param.new("c")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.in("valid", ["a", "b"])
  check v.hasErrors == false
  v.in("invalid", ["a", "b"])
  check v.hasErrors
  check v.errors["invalid"][0] == "The selected invalid is invalid."


block:
  let p = Params.new()
  p["base"] = Param.new("a")
  p["valid"] = Param.new("a, b, c")
  p["invalid"] = Param.new("b, c")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.inArray("base", "valid")
  check v.hasErrors == false
  v.inArray("base", "invalid")
  check v.hasErrors
  check v.errors["base"][0] == "The base field does not exist in invalid."

block:
  let p = Params.new()
  p["valid"] = Param.new("1")
  p["invalid"] = Param.new("a")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.integer("valid")
  v.integer(["valid"])
  check v.hasErrors == false
  v.integer("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be an integer."


block:
  let p = Params.new()
  p["valid"] = Param.new("""{"key": "value"}""")
  p["invalid"] = Param.new("a")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.json("valid")
  v.json(["valid"])
  check v.hasErrors == false
  v.json("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a valid JSON string."


block:
  let p = Params.new()
  p["base"] = Param.new("2")
  p["smaller"] = Param.new("1")
  p["bigger"] = Param.new("3")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.ltNum("base", "bigger")
  check v.hasErrors == false
  v.ltNum("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than smaller."

block:
  let p = Params.new()
  p["base"] = Param.new("a".repeat(2*1024), "base", "jpg")
  p["smaller"] = Param.new("a".repeat(1*1024), "smaller", "jpg")
  p["bigger"] = Param.new("a".repeat(3*1024), "bigger", "jpg")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.ltFile("base", "bigger")
  check v.hasErrors == false
  v.ltFile("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than 1.0 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param.new("ab")
  p["smaller"] = Param.new("a")
  p["bigger"] = Param.new("abc")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.ltStr("base", "bigger")
  check v.hasErrors == false
  v.ltStr("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than smaller characters."

block:
  let p = Params.new()
  p["base"] = Param.new("a, b")
  p["smaller"] = Param.new("a")
  p["bigger"] = Param.new("a, b, c")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.ltArr("base", "bigger")
  check v.hasErrors == false
  v.ltArr("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must have less than smaller items."


block:
  let p = Params.new()
  p["base"] = Param.new("2")
  p["same"] = Param.new("2")
  p["smaller"] = Param.new("1")
  p["bigger"] = Param.new("3")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.lteNum("base", "bigger")
  v.lteNum("base", "same")
  check v.hasErrors == false
  v.lteNum("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than or equal smaller."

block:
  let p = Params.new()
  p["base"] = Param.new("a".repeat(2*1024), "base", "jpg")
  p["same"] = Param.new("a".repeat(2*1024), "same", "jpg")
  p["smaller"] = Param.new("a".repeat(1*1024), "smaller", "jpg")
  p["bigger"] = Param.new("a".repeat(3*1024), "bigger", "jpg")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.lteFile("base", "bigger")
  v.lteFile("base", "same")
  check v.hasErrors == false
  v.lteFile("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than or equal 1 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param.new("ab")
  p["same"] = Param.new("ab")
  p["smaller"] = Param.new("a")
  p["bigger"] = Param.new("abc")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.lteStr("base", "bigger")
  v.lteStr("base", "same")
  check v.hasErrors == false
  v.lteStr("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must be less than or equal smaller characters."

block:
  let p = Params.new()
  p["base"] = Param.new("a, b")
  p["same"] = Param.new("a, b")
  p["smaller"] = Param.new("a")
  p["bigger"] = Param.new("a, b, c")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.lteArr("base", "bigger")
  v.lteArr("base", "same")
  check v.hasErrors == false
  v.lteArr("base", "smaller")
  check v.hasErrors
  check v.errors["base"][0] == "The base must not have more than smaller items."


block:
  let p = Params.new()
  p["base"] = Param.new("2")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.maxNum("base", 3)
  v.maxNum("base", 2)
  check v.hasErrors == false
  v.maxNum("base", 1)
  check v.hasErrors
  check v.errors["base"][0] == "The base may not be greater than 1."

block:
  let p = Params.new()
  p["base"] = Param.new("a".repeat(2*1024), "base", "jpg")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.maxFile("base", 3)
  v.maxFile("base", 2)
  check v.hasErrors == false
  v.maxFile("base", 1)
  check v.hasErrors
  check v.errors["base"][0] == "The base may not be greater than 1 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param.new("ab")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.maxStr("base", 3)
  v.maxStr("base", 2)
  check v.hasErrors == false
  v.maxStr("base", 1)
  check v.hasErrors
  check v.errors["base"][0] == "The base may not be greater than 1 characters."

block:
  let p = Params.new()
  p["base"] = Param.new("a, b")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.maxArr("base", 3)
  v.maxArr("base", 2)
  check v.hasErrors == false
  v.maxArr("base", 1)
  check v.hasErrors
  check v.errors["base"][0] == "The base may not have more than 1 items."


block:
  let p = Params.new()
  p["valid"] = Param.new("a", "valid", "jpg")
  p["invalid"] = Param.new("a", "invalid.mp4", "mp4")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.mimes("valid", ["jpg", "png", "gif"])
  check v.hasErrors == false
  v.mimes("invalid", ["jpg", "png", "gif"])
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a file of type: [\"jpg\", \"png\", \"gif\"]."


block:
  let p = Params.new()
  p["base"] = Param.new("2")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.minNum("base", 1)
  v.minNum("base", 2)
  check v.hasErrors == false
  v.minNum("base", 3)
  check v.hasErrors
  check v.errors["base"][0] == "The base must be at least 3."

block:
  let p = Params.new()
  p["base"] = Param.new("a".repeat(2*1024), "base", "jpg")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.minFile("base", 1)
  v.minFile("base", 2)
  check v.hasErrors == false
  v.minFile("base", 3)
  check v.hasErrors
  check v.errors["base"][0] == "The base must be at least 3 kilobytes."

block:
  let p = Params.new()
  p["base"] = Param.new("ab")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.minStr("base", 1)
  v.minStr("base", 2)
  check v.hasErrors == false
  v.minStr("base", 3)
  check v.hasErrors
  check v.errors["base"][0] == "The base must be at least 3 characters."

block:
  let p = Params.new()
  p["base"] = Param.new("a, b")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.minArr("base", 1)
  v.minArr("base", 2)
  check v.hasErrors == false
  v.minArr("base", 3)
  check v.hasErrors
  check v.errors["base"][0] == "The base must have at least 3 items."


block:
  let p = Params.new()
  p["valid"] = Param.new("a")
  p["invalid"] = Param.new("b")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.notIn("valid", ["b", "c"])
  check v.hasErrors == false
  v.notIn("invalid", ["b", "c"])
  check v.hasErrors
  check v.errors["invalid"][0] == "The selected invalid is invalid."


block:
  let p = Params.new()
  p["base"] = Param.new("abc")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.notRegex("base", re"\d")
  check v.hasErrors == false
  v.notRegex("base", re"\w")
  check v.hasErrors
  check v.errors["base"][0] == "The base format is invalid."


block:
  let p = Params.new()
  p["valid"] = Param.new("-1.23")
  p["invalid"] = Param.new("abc")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.numeric("valid")
  v.numeric(["valid"])
  check v.hasErrors == false
  v.numeric("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a number."



block:
  let p = Params.new()
  p["valid"] = Param.new("a")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.present("valid")
  v.present(["valid"])
  check v.hasErrors == false
  v.present("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid field must be present."


block:
  let p = Params.new()
  p["base"] = Param.new("abc")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.regex("base", re"\w")
  check v.hasErrors == false
  v.regex("base", re"\d")
  check v.hasErrors
  check v.errors["base"][0] == "The base format is invalid."

block:
  let p = Params.new()
  p["valid"] = Param.new("abc")
  p["invalid1"] = Param.new("")
  p["invalid2"] = Param.new("null")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.required("valid")
  check v.hasErrors == false
  v.required("invalid1")
  v.required("invalid2")
  check v.hasErrors
  check v.errors["invalid1"][0] == "The invalid1 field is required."
  check v.errors["invalid2"][0] == "The invalid2 field is required."

block:
  let p = Params.new()
  p["other"] = Param.new("123")
  p["valid"] = Param.new("abc")
  p["invalid1"] = Param.new("")
  p["invalid2"] = Param.new("null")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["other"] = Param.new("123")
  p["valid"] = Param.new("abc")
  p["invalid1"] = Param.new("")
  p["invalid2"] = Param.new("null")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["other"] = Param.new("123")
  p["valid"] = Param.new("abc")
  p["invalid1"] = Param.new("")
  p["invalid2"] = Param.new("null")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["other1"] = Param.new("123")
  p["other2"] = Param.new("123")
  p["valid"] = Param.new("abc")
  p["invalid1"] = Param.new("")
  p["invalid2"] = Param.new("null")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["other1"] = Param.new("123")
  p["other2"] = Param.new("123")
  p["valid"] = Param.new("abc")
  p["invalid1"] = Param.new("")
  p["invalid2"] = Param.new("null")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["valid"] = Param.new("abc")
  p["other"] = Param.new("123")
  p["invalid1"] = Param.new("")
  p["invalid2"] = Param.new("null")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["a"] = Param.new("a")
  p["b"] = Param.new("a")
  p["c"] = Param.new("c")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.same("a", "b")
  check v.hasErrors == false
  v.same("a", "c")
  check v.hasErrors
  check v.errors["a"][0] == "The a and c must match."

block:
  let p = Params.new()
  p["num"] = Param.new("2")
  p["file"] = Param.new("a".repeat(2*1024), "file", "jpg")
  p["str"] = Param.new("ab")
  p["arr"] = Param.new("a, b")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
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
  p["base"] = Param.new("abcde")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.startsWith("base", ["abc", "bcd"])
  check v.hasErrors == false
  v.startsWith("base", ["bcd", "cde"])
  check v.hasErrors
  check v.errors["base"][0] == "The base must be start with one of following [\"bcd\", \"cde\"]."

block:
  let p = Params.new()
  p["validtimestamp"] = Param.new("1577804400")
  p["invalidtimestamp"] = Param.new("18446744073709551615")
  p["negative"] = Param.new("-1")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.timestamp("validtimestamp")
  check v.hasErrors == false
  v.timestamp("negative")
  v.timestamp("invalidtimestamp")
  check v.errors["negative"][0] == "The negative is not a valid timestamp."
  check v.errors["invalidtimestamp"][0] == "The invalidtimestamp is not a valid timestamp."

block:
  let p = Params.new()
  p["valid"] = Param.new("https://google.com:8000/xxx/yyy/zzz?key=value")
  p["invalid"] = Param.new("fnyuaAxmoiniancywcnsnmuaic")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.url("valid")
  v.url(["valid"])
  check v.hasErrors == false
  v.url("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid format is invalid."

block:
  let p = Params.new()
  p["valid"] = Param.new("a0a2a2d2-0b87-4a18-83f2-2529882be2de")
  p["invalid"] = Param.new("iuajfassacds")
  let request = Request()
  let context = Context.new(request, p).waitFor()
  let v = RequestValidation.new(context)
  v.uuid("valid")
  v.uuid(["valid"])
  check v.hasErrors == false
  v.uuid("invalid")
  check v.hasErrors
  check v.errors["invalid"][0] == "The invalid must be a valid UUID."
