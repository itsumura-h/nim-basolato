discard """
  cmd: "nim c -d:test $file"
"""

import std/unittest
import std/times
include ../src/basolato/core/libservers/std/request
include ../src/basolato/request_validation


suite("Validation"):
  test("accepted"):
    let v = Validation.new()
    check v.accepted("on")
    check v.accepted("yes")
    check v.accepted("1")
    check v.accepted("true")
    check v.accepted("a") == false

  test("after"):
    let v = Validation.new()
    let a = "2020-01-02".parse("yyyy-MM-dd")
    let b = "2020-01-01".parse("yyyy-MM-dd")
    let c = "2020-01-03".parse("yyyy-MM-dd")
    check v.after(a, b)
    check v.after(a, c) == false

  test("afterOrEqual"):
    let v = Validation.new()
    let base = "2020-01-02".parse("yyyy-MM-dd")
    let before = "2020-01-01".parse("yyyy-MM-dd")
    let after = "2020-01-03".parse("yyyy-MM-dd")
    let same = "2020-01-02".parse("yyyy-MM-dd")
    check v.afterOrEqual(base, before)
    check v.afterOrEqual(base, same)
    check v.afterOrEqual(base, after) == false

  test("alpha"):
    let v = Validation.new()
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

  test("alphaDash"):
    let v = Validation.new()
    const letter = "abcAbc012"
    const withDash = "abcAbc012-_"
    const ja = "aA0あいうえお"
    check v.alphaDash(letter)
    check v.alphaDash(withDash)
    check v.alphaDash(ja) == false

  test("alphaNum"):
    let v = Validation.new()
    const letter = "abcABC012"
    const withDash = "abcABC012-_"
    const ja = "aA0あいうえお"
    check v.alphaNum(letter)
    check v.alphaNum(withDash) == false
    check v.alphaNum(ja) == false

  test("array"):
    let v = Validation.new()
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

  test("before"):
    let v = Validation.new()
    let a = "2020-01-02".parse("yyyy-MM-dd")
    let b = "2020-01-01".parse("yyyy-MM-dd")
    let c = "2020-01-03".parse("yyyy-MM-dd")
    check v.before(a, c)
    check v.before(a, b) == false

  test("beforeOrEqual"):
    let v = Validation.new()
    let base = "2020-01-02".parse("yyyy-MM-dd")
    let before = "2020-01-01".parse("yyyy-MM-dd")
    let after = "2020-01-03".parse("yyyy-MM-dd")
    let same = "2020-01-02".parse("yyyy-MM-dd")
    check v.beforeOrEqual(base, after)
    check v.beforeOrEqual(base, same)
    check v.beforeOrEqual(base, before) == false

  test("between"):
    let v = Validation.new()
    check v.between(2, 1, 3)
    check v.between(1, 2, 3) == false
    check v.between(1.1, 2, 3.1) == false
    check v.between("aaa", 2, 3)
    check v.between("a", 2, 3) == false
    check v.between(["a", "a", "a"], 2, 3)
    check v.between(["a"], 2, 3) == false
    check v.betweenFile("a".repeat(2000), 1, 3)
    check v.betweenFile("a".repeat(2000), 2, 3) == false

  test("boolean"):
    let v = Validation.new()
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

  test("date"):
    let v = Validation.new()
    check v.date("2020-01-01", "yyyy-MM-dd")
    check v.date("aaa", "yyyy-MM-dd") == false
    check v.date("1577804400")
    check v.date($high(int))
    check v.date("aaa") == false
    check v.date($high(uint64)) == false

  test("dateEquals"):
    let v = Validation.new()
    check v.dateEquals("2020-01-01", "yyyy-MM-dd", "2020-01-01".parse("yyyy-MM-dd"))
    check v.dateEquals("a", "a", "2020-01-01".parse("yyyy-MM-dd")) == false
    check v.dateEquals("1577880000", "2020-01-01".parse("yyyy-MM-dd"))
    check v.dateEquals("1577980000", "2020-01-01".parse("yyyy-MM-dd")) == false

  test("different"):
    let v = Validation.new()
    check v.different("a", "b")
    check v.different("a", "a") == false

  test("digits"):
    let v = Validation.new()
    check v.digits(11, 2)
    check v.digits(111, 2) == false

  test("digitsBetween"):
    let v = Validation.new()
    check v.digits_between(11, 1, 3)
    check v.digits_between(111, 4, 5) == false

  test("distinctArr"):
    let v = Validation.new()
    check v.distinctArr(@["a", "b", "c"])
    check v.distinctArr(@["a", "b", "b"]) == false

  test("domain"):
    let v = Validation.new()
    check v.domain("domain.com")
    check v.domain("[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]")
    check v.domain("[2001:0db8:bd05:01d2:288a::1fc0:0001:10ee]") == false

  test("email"):
    let v = Validation.new()
    check v.email("email@domain.com")
    check not v.email("Abc.@example.com")

  test("endsWith"):
    let v = Validation.new()
    check v.endsWith("abcdefg", ["fg"])
    check v.endsWith("abcdefg", ["gh"]) == false

  test("file"):
    let v = Validation.new()
    check v.file("aaa", "jpg")
    check v.file("aaa", "") == false

  test("filled"):
    let v = Validation.new()
    check v.filled("a")
    check v.filled("") == false

  test("gt"):
    let v = Validation.new()
    check v.gt(2, 1)
    check v.gt(2, 3) == false
    check v.gt("ab", "a")
    check v.gt("ab", "abc") == false
    check v.gt(["a", "b"], ["a"])
    check v.gt(["a", "b"], ["a", "b", "c"]) == false

  test("gte"):
    let v = Validation.new()
    check v.gte(2, 1)
    check v.gte(2, 2)
    check v.gte(2, 3) == false
    check v.gte("ab", "a")
    check v.gte("ab", "aa")
    check v.gte("ab", "abc") == false
    check v.gte(["a", "b"], ["a"])
    check v.gte(["a", "b"], ["a", "b"])
    check v.gte(["a", "b"], ["a", "b", "c"]) == false

  test("image"):
    let v = Validation.new()
    check v.image("jpg")
    check v.image("nim") == false

  test("in"):
    let v = Validation.new()
    check v.in("a", ["a", "b"])
    check v.in("c", ["a", "b"]) == false


  test("integer"):
    let v = Validation.new()
    check v.integer("1")
    check v.integer("1686246286")
    check v.integer("a") == false

  test("json"):
    let v = Validation.new()
    check v.json("""{"str": "value", "int": 1, "float": 1.1, "bool": true}""")
    check v.json("a") == false

  test("lt"):
    let v = Validation.new()
    check v.lt(2, 3)
    check v.lt(2, 1) == false
    check v.lt("ab", "abc")
    check v.lt("ab", "ab") == false
    check v.lt(["a", "b"], ["a", "b", "c"])
    check v.lt(["a", "b"], ["a"]) == false

  test("lte"):
    let v = Validation.new()
    check v.lte(2, 3)
    check v.lte(2, 2)
    check v.lte(2, 1) == false
    check v.lte("ab", "abc")
    check v.lte("ab", "aa")
    check v.lte("ab", "a") == false
    check v.lte(["a", "b"], ["a", "b", "c"])
    check v.lte(["a", "b"], ["a", "b"])
    check v.lte(["a", "b"], ["a"]) == false

  test("max"):
    let v = Validation.new()
    check v.max(2, 3)
    check v.max(2, 1) == false
    check v.max("ab", 3)
    check v.max("ab", 1) == false
    check v.max(["a", "b"], 3)
    check v.max(["a", "b"], 1) == false

  test("mimes"):
    let v = Validation.new()
    check v.mimes("jpg", ["jpg", "png", "gif"])
    check v.mimes("mp4", ["jpg", "png", "gif"]) == false

  test("min"):
    let v = Validation.new()
    check v.min(2, 1)
    check v.min(2, 3) == false
    check v.min("ab", 1)
    check v.min("ab", 3) == false
    check v.min(["a", "b"], 1)
    check v.min(["a", "b"], 3) == false

  test("notIn"):
    let v = Validation.new()
    check v.notIn("a", ["b", "c"])
    check v.notIn("b", ["b", "c"]) == false

  test("notRegex"):
    let v = Validation.new()
    check v.notRegex("abc", re"\d")
    check v.notRegex("abc", re"\w") == false

  test("numeric"):
    let v = Validation.new()
    check v.numeric("-1.23")
    check v.numeric("abc") == false

  test("regex"):
    let v = Validation.new()
    check v.regex("abc", re"\w")
    check v.regex("abc", re"\d") == false

  test("required"):
    let v = Validation.new()
    check v.required("abc")
    check v.required("") == false
    check v.required("null") == false

  test("same"):
    let v = Validation.new()
    check v.same("a", "a")
    check v.same("a", "b") == false

  test("size"):
    let v = Validation.new()
    check v.size(1, 1)
    check v.size(1, 2) == false
    check v.size("a", 1)
    check v.size("a", 2) == false
    check v.sizeFile("a".repeat(1025), 1)
    check v.sizeFile("a".repeat(2048), 1) == false
    check v.size(["a"], 1)
    check v.size(["a"], 2) == false

  test("startsWith"):
    let v = Validation.new()
    check v.startsWith("abcde", ["abc", "bcd"])
    check v.startsWith("abcde", ["bcd", "cde"]) == false

  test("url"):
    let v = Validation.new()
    check v.url("https://google.com:8000/xxx/yyy/zzz?key=value")
    check v.url("fnyuaAxmoiniancywcnsnmuaic") == false

  test("uuid"):
    let v = Validation.new()
    check v.uuid("a0a2a2d2-0b87-4a18-83f2-2529882be2de")
    check v.uuid("aiuimacuca") == false
