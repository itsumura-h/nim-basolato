Validation
===
[Back](../../README.md)

Table of Contents
<!--ts-->
* [Validation](#validation)
* [Simple Validation](#simple-validation)
   * [Example](#example)
* [Request Validation](#request-validation)
      * [API](#api)
   * [Example](#example-1)
* [Error Messages](#error-messages)
   * [Locale](#locale)
   * [Replacing Request Parameter Keys](#replacing-request-parameter-keys)
* [Rules](#rules)
   * [accepted](#accepted)
   * [after](#after)
   * [afterOrEqual](#afterorequal)
   * [alpha](#alpha)
   * [alphaDash](#alphadash)
   * [alphaNum](#alphanum)
   * [array](#array)
   * [before](#before)
   * [beforeOrEqual](#beforeorequal)
   * [betweenNum](#betweennum)
   * [betweenStr](#betweenstr)
   * [betweenArr](#betweenarr)
   * [betweenFile](#betweenfile)
   * [boolean](#boolean)
   * [confirmed](#confirmed)
   * [date](#date)
   * [dateEquals](#dateequals)
   * [different](#different)
   * [digits](#digits)
   * [digitsBetween](#digitsbetween)
   * [distinctArr](#distinctarr)
   * [domain](#domain)
   * [email](#email)
   * [endsWith](#endswith)
   * [file](#file)
   * [filled](#filled)
   * [gtNum](#gtnum)
   * [gtFile](#gtfile)
   * [gtStr](#gtstr)
   * [gtArr](#gtarr)
   * [gteNum](#gtenum)
   * [gteFile](#gtefile)
   * [gteStr](#gtestr)
   * [gteArr](#gtearr)
   * [image](#image)
   * [in](#in)
   * [inArray](#inarray)
   * [integer](#integer)
   * [json](#json)
   * [ltNum](#ltnum)
   * [ltFile](#ltfile)
   * [ltStr](#ltstr)
   * [ltArr](#ltarr-1)
   * [maxNum](#maxnum)
   * [maxFile](#maxfile)
   * [maxStr](#maxstr)
   * [maxArr](#maxarr)
   * [mimes](#mimes)
   * [minNum](#minnum)
   * [minFile](#minfile)
   * [minStr](#minstr)
   * [minArr](#minarr)
   * [notIn](#notin)
   * [notRegex](#notregex)
   * [numeric](#numeric)
   * [present](#present)
   * [regex](#regex)
   * [required](#required)
   * [requiredIf](#requiredif)
   * [requiredUnless](#requiredunless)
   * [requiredWith](#requiredwith)
   * [requiredWithAll](#requiredwithall)
   * [requiredWithout](#requiredwithout)
   * [same](#same)
   * [sizeNum](#sizenum)
   * [sizeFile](#sizefile)
   * [sizeStr](#sizestr)
   * [sizeArr](#sizearr)
   * [startsWith](#startswith)
   * [timestamp](#timestamp)
   * [url](#url)
   * [uuid](#uuid)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 11:26:15 UTC 2024 -->

<!--te-->

Basolato has its own validation feature. This feature receives a request and checks the request parameters.  
There are two types of validation. One is used in controllers that receive a request and return an array of errors.  
The other is simpler and receives a value and returns a `bool`.

# Simple Validation
```
import basolato/core/validation
```
## Example
```nim
let validation = Validation.new()

echo validation.email("sample@example.com")
>> true

echo validation.email("sample@example")
>> false
```

# Request Validation
```
import basolato/request_validation
```
### API
```nim
proc new*(_:type RequestValidation, params: Params):RequestValidation

proc hasErrors*(self:RequestValidation):bool

proc hasError*(self:RequestValidation, key:string):bool

proc errors*(self:RequestValidation):ValidationErrors

proc add*(self:ValidationErrors, key, value:string)

proc storeValidationResult*(context:Context, validation:RequestValidation) {.async.}
```
`storeValidationResult` saves the request parameters and validation error messages as flash messages in the session.

## Example
Form Request
```html
<input type="base" name="email" value="user1@example.com">
```
JSON Request
```json
{
  "email": "user1@example.com"
}
```
```nim
proc signUp*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  v.required("email")
  v.email("email")
  if v.hasErrors:
    context.storeValidationResult(v).await
    return redirect("/signup")
```
```nim
echo context.getFlash().await
>> {
  "errors": {
    "email": ["The name field is required."]
  },
  "params": {
    "email": "user1@example.com"
  }
}
```
# Error Messages
## Locale
Error messages are defined in `resources/lang/{locale}/validation.json`. 
The default locale is `en`. To replace this, define the environment variable `LOCALE`.

## Replacing Request Parameter Keys
By default, the error message contains the request parameter key name. This can be replaced by specifying an `attribute`.

Initial state
```nim
let v = RequestValidation.new(context)
v.required("name")
v.errors["name"][0] == "The name field is required."
```

Replacement
```nim
let v = RequestValidation.new(context)
v.required("name", attribute="User Name")
v.errors["name"][0] == "The User Name field is required."
```

# Rules
Refer to the test codes of [simple validation](../../tests/test_validation.nim) and [request validation](../../tests/test_request_validation.nim) for more examples.

## accepted
Validates that the field is yes, on, 1, or true. This is useful for "terms of service" acceptance validation.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "on"
  v.accepted("base")
  assert v.hasErrors == false
```

## after
Validates that the field's value is after the given date.  
You can specify either a `Datetime` type or another field name to compare with.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "2020-01-01"
  assert context.params.getStr("target") == "2020-01-02"
  v.after("base", "target", "yyyy-MM-dd")
  v.after("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  assert v.hasErrors == false
```

## afterOrEqual
Validates that the field's value is after or equal to the given date.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "2020-01-01"
  assert context.params.getStr("same") == "2020-01-01"
  assert context.params.getStr("target") == "2020-01-02"
  v.afterOrEqual("base", "target", "yyyy-MM-dd")
  v.afterOrEqual("base", "same", "yyyy-MM-dd")
  v.afterOrEqual("base", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  v.afterOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  assert v.hasErrors == false
```

## alpha
Validates that the field contains only alphabetic characters.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("small") == "abcdefghijklmnopqrstuvwxyz"
  assert context.params.getStr("large") == "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  v.alpha("small")
  v.alpha("large")
  assert v.hasErrors == false
```

## alphaDash
Validates that the field contains only alphabetic characters, numbers, dashes (-), and underscores (_).
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abcABC012-_"
  v.alphaDash("base")
  assert v.hasErrors == false
```

## alphaNum
Validates that the field contains only alphabetic characters and numbers.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abcABC012"
  v.alphaNum("base")
  assert v.hasErrors == false
```

## array
Validates that the field is an array.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a, b, c"
  v.array("base")
  assert v.hasErrors == false
```

## before
Validates that the field's value is before the given date.  
Similar to the `after` rule, you can specify either a `Datetime` type or another field name to compare with.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "2020-01-02"
  assert context.params.getStr("target") == "2020-01-01"
  v.before("base", "target", "yyyy-MM-dd")
  v.before("base", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  assert v.hasErrors == false
```

## beforeOrEqual
Validates that the field's value is before or equal to the given date.  
Similar to the `after` rule, you can specify either a `Datetime` type or another field name to compare with.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "2020-01-02"
  assert context.params.getStr("same") == "2020-01-02"
  assert context.params.getStr("target") == "2020-01-01"
  v.beforeOrEqual("base", "target", "yyyy-MM-dd")
  v.beforeOrEqual("base", "same", "yyyy-MM-dd")
  v.beforeOrEqual("base", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  v.beforeOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  assert v.hasErrors == false
```

## betweenNum
Validates that the field's value is between the specified minimum and maximum values.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getInt("int") == 2
  assert context.params.getFloat("float") == 2.0
  v.betweenNum("int", 1, 3)
  v.betweenNum("float", 1.9, 2.1)
  assert v.hasErrors == false
```

## betweenStr
Validates that the field's value is between the specified minimum and maximum character lengths.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("str") == "ab"
  v.betweenStr("str", 1, 3)
  assert v.hasErrors == false
```

## betweenArr
Validates that the field's value is between the specified minimum and maximum array lengths.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("arr") == "a, b"
  v.betweenArr("arr", 1, 3)
  assert v.hasErrors == false
```

## betweenFile
Validates that the field's file size is between the specified minimum and maximum values.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("file").len == 2048
  v.betweenFile("file", 1, 3)
  assert v.hasErrors == false
```

## boolean
Validates that the field is a boolean value.  
Acceptable input values are `y, yes, true, 1, on, n, no, false, 0, off`.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("bool") == "true"
  v.boolean("bool")
  assert v.hasErrors == false
```

## confirmed
Validates that the field's value is the same as the field_name_confirmation field's value. For example, if the field being validated is password, the value must match the password_confirmation field's value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("password") == "aaa"
  assert context.params.getStr("password_confirmation") == "aaa"
  assert context.params.getStr("password_check") == "aaa"
  v.confirmed("password")
  v.confirmed("password", suffix="_check")
  assert v.hasErrors == false
```

## date
Validates that the field's value is a valid date and not a relative date.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "2020-01-01"
  v.date("base", "yyyy-MM-dd")
  assert v.hasErrors == false
```

## dateEquals
Validates that the field's value is equal to the specified `Datetime`.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("date") == "2020-01-01"
  assert context.params.getStr("timestamp") == "1577880000"
  let target = "2020-01-01".format("yyyy-MM-dd")
  v.dateEquals("base", "yyyy-MM-dd", target)
  v.dateEquals("timestamp", target)
  assert v.hasErrors == false
```

## different
Validates that the field's value is different from the specified field's value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a"
  assert context.params.getStr("target") == "b"
  v.different("base", "target")
  assert v.hasErrors == false
```

## digits
Validates that the field is numeric and has the specified number of digits.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "10"
  v.digits("base", 2)
  assert v.hasErrors == false
```

## digitsBetween
Validates that the field is numeric and has a number of digits between the specified minimum and maximum.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "10"
  v.digitsBetween("base", 1, 3)
  assert v.hasErrors == false
```

## distinctArr
Validates that the field is an array and contains no duplicate values.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a, b, c"
  v.distinctArr("base")
  assert v.hasErrors == false
```

## domain
Validates that the field is a valid `A` or `AAAA` record.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("v4")

 == "domain.com"
  assert context.params.getStr("v6") == "[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]"
  v.domain("v4")
  v.domain("v6")
  assert v.hasErrors == false
```

## email
Validates that the field is a valid email address.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "email@domain.com"
  v.email("base")
  assert v.hasErrors == false
```

This implementation is based on the following Python code:  
https://gist.github.com/frodo821/681869a36148b5214632166e0ad293a9

## endsWith
Validates that the field's value ends with one of the specified values.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abcdefg"
  v.endsWith("base", ["ef", "fg"])
  assert v.hasErrors == false
```

## file
Validates that the field is a successfully uploaded file.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert params["base"].ext == "jpg"
  v.file("base")
  assert v.hasErrors == false
```

## filled
Validates that the field is not empty if it is present.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a"
  v.filled("base")
  assert v.hasErrors == false
```

## gtNum
Validates that the field's value is greater than the specified field's value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getInt("base") == 2
  assert context.params.getInt("target") == 1
  v.gtNum("base", "target")
  assert v.hasErrors == false
```

## gtFile
Validates that the field's file size is greater than the specified field's file size.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base").len == 2048
  assert params["base"].ext == "jpg"
  assert context.params.getStr("target").len == 1024
  assert params["target"].ext == "jpg"
  v.gtFile("base", "target")
  assert v.hasErrors == false
```

## gtStr
Validates that the field's value is longer than the specified field's value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "ab"
  assert context.params.getStr("target") == "a"
  v.gtStr("base", "target")
  assert v.hasErrors == false
```

## gtArr
Validates that the field's array length is greater than the specified field's array length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a, b"
  assert context.params.getStr("target") == "a"
  v.gtArr("base", "target")
  assert v.hasErrors == false
```

## gteNum
Validates that the field's value is greater than or equal to the specified field's value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getInt("base") == 2
  assert context.params.getInt("same") == 2
  assert context.params.getInt("target") == 1
  v.gteNum("base", "target")
  v.gteNum("base", "same")
  assert v.hasErrors == false
```

## gteFile
Validates that the field's file size is greater than or equal to the specified field's file size.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base").len == 2048
  assert context.params.getStr("same").len == 2048
  assert context.params.getStr("target").len == 1024
  v.gteFile("base", "target")
  v.gteFile("base", "same")
  assert v.hasErrors == false
```

## gteStr
Validates that the field's value is greater than or equal to the specified field's value in length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "ab"
  assert context.params.getStr("same") == "bc"
  assert context.params.getStr("target") == "a"
  v.gteStr("base", "target")
  v.gteStr("base", "same")
  assert v.hasErrors == false
```

## gteArr
Validates that the field's array length is greater than or equal to the specified field's array length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a, b"
  assert context.params.getStr("same") == "b, c"
  assert context.params.getStr("target") == "a"
  v.gteArr("base", "target")
  v.gteArr("base", "same")
  assert v.hasErrors == false
```

## image
Validates that the field is an image (jpg, png, bmp, gif, svg, webp).
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert params["base"].ext == "jpg"
  v.image("base")
  assert v.hasErrors == false
```

## in
Validates that the field's value is included in the specified list.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert params["base"].ext == "a"
  v.in("base", ["a", "b"])
  assert v.hasErrors == false
```

## inArray
Validates that the field's value is one of the values in the specified field.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a"
  assert context.params.getStr("target") == "a, b, c"
  v.inArray("base", "target")
  assert v.hasErrors == false
```

## integer
Validates that the field is an integer.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getInt("base") == 1
  v.integer("base")
  assert v.hasErrors == false
```

## json
Validates that the field is a valid JSON string.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == """{"key": "value"}"""
  v.json("base")
  assert v.hasErrors == false
```

## ltNum
Validates that the field's value is less than the specified field's value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getInt("base") == 1
  assert context.params.getInt("target") == 2
  v.ltNum("base", "target")
  assert v.hasErrors == false
```

## ltFile
Validates that the field's file size is less than the specified field's file size.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base").len == 1024
  assert context.params.getStr("target").len == 2048
  v.ltFile("base", "target")
  assert v.hasErrors == false
```

## ltStr
Validates that the field's value is shorter than the specified field's value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
 

 assert context.params.getStr("base") == "a"
  assert context.params.getStr("target") == "ab"
  v.ltStr("base", "target")
  assert v.hasErrors == false
```

## ltArr
Validates that the field's array length is shorter than the specified field's array length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a"
  assert context.params.getStr("target") == "a, b"
  v.ltArr("base", "target")
  assert v.hasErrors == false
```

## lteNum
Validates that the field's value is less than or equal to the specified field's value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getInt("base") == 1
  assert context.params.getInt("same") == 1
  assert context.params.getInt("target") == 2
  v.lteNum("base", "target")
  v.lteNum("base", "same")
  assert v.hasErrors == false
```

## lteFile
Validates that the field's file size is less than or equal to the specified field's file size.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base").len == 1024
  assert context.params.getStr("same").len == 1024
  assert context.params.getStr("target").len == 2048
  v.lteFile("base", "target")
  v.lteFile("base", "same")
  assert v.hasErrors == false
```

## lteStr
Validates that the field's value is shorter than or equal to the specified field's value in length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a"
  assert context.params.getStr("same") == "b"
  assert context.params.getStr("target") == "ab"
  v.lteStr("base", "target")
  v.lteStr("base", "same")
  assert v.hasErrors == false
```

## ltArr
Validates that the field's array length is less than or equal to the specified field's array length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a"
  assert context.params.getStr("same") == "a"
  assert context.params.getStr("target") == "a, b"
  v.lteArr("base", "target")
  v.lteArr("base", "same")
  assert v.hasErrors == false
```

## maxNum
Validates that the field's value is less than or equal to the specified maximum value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getInt("base") == 2
  assert context.params.getInt("small") == 1
  v.maxNum("base", 2)
  v.maxNum("small", 2)
  assert v.hasErrors == false
```

## maxFile
Validates that the field's file size is less than or equal to the specified maximum value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base").len == 2048
  assert context.params.getStr("small").len == 1024
  v.maxFile("base", 2)
  v.maxFile("small", 2)
  assert v.hasErrors == false
```

## maxStr
Validates that the field's value is shorter than or equal to the specified maximum character length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "ab"
  assert context.params.getStr("small") == "a"
  v.maxStr("base", 2)
  v.maxStr("small", 2)
  assert v.hasErrors == false
```

## maxArr
Validates that the field's array length is less than or equal to the specified maximum length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a, b"
  assert context.params.getStr("small") == "a"
  v.maxArr("base", 2)
  v.maxArr("small", 2)
  assert v.hasErrors == false
```

## mimes
Validates that the field's file is one of the specified MIME types.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert params["base"].ext == "jpg"
  v.mimes("base", ["jpg", "gif"])
  assert v.hasErrors == false
```

## minNum
Validates that the field's value is greater than or equal to the specified minimum value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getInt("base") == 2
  v.minNum("base", 1)
  v.minNum("base", 2)
  assert v.hasErrors == false
```

## minFile
Validates that the field's file size is greater than or equal to the specified minimum value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base").len == 2048
  v.minFile("base", 1)
  v.minFile("base", 2)
  assert v.hasErrors == false
```

## minStr
Validates that the field's value is longer than or equal to the specified minimum character length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "ab"
  v.minStr("base", 1)
  v.minStr("base", 2)
  assert v.hasErrors == false
```

## minArr
Validates that the field's array length is longer than or equal to the specified minimum length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a, b"
  v.minArr("base", 1)
  v.minArr("base", 2)
  assert v.hasErrors == false
```

## notIn
Validates that the field's value is not included in the specified list.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a"
  v.notIn("base", ["b", "c"])
  assert v.hasErrors == false
```

## notRegex
Validates that the field's value does not match the specified regular expression.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abc"
  v.notRegex("base", re"\d")
  assert v.hasErrors == false
```

## numeric
Validates that the field is a numeric value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getInt("base") == 1
  assert context.params.getFloat("float") == -1.23
  v.numeric("base")
  v.numeric("float")
  assert v.hasErrors == false
```

## present
Validates that the field is present in the input data, but allows it to be empty.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == ""
  v.present("base")
  assert v.hasErrors == false
```

## regex
Validates that the field's value matches the specified regular expression.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abc"
  v.regex("base", re"\w")
  assert v.hasErrors == false
```

## required
Validates that the field is present in the input data and is not empty. A field is

 considered "empty" if it meets any of the following conditions:
- The value is `null`.
- The value is an empty string.
- The value is an empty array or empty `Countable` object.
- The value is an uploaded file with no path.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abc"
  v.required("base")
  assert v.hasErrors == false
```

## requiredIf
Validates that the field is present and not empty if another field is equal to any of the specified values.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abc"
  assert context.params.getStr("empty") == ""
  assert context.params.getStr("other") == "123"
  v.requiredIf("base", "other", ["123"])
  v.requiredIf("empty", "other", ["xyz"])
  assert v.hasErrors == false
```

## requiredUnless
Validates that the field is present and not empty unless another field is equal to any of the specified values.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abc"
  assert context.params.getStr("empty") == ""
  assert context.params.getStr("other") == "123"
  v.requiredUnless("base", "other", ["123"])
  v.requiredUnless("empty", "other", ["123"])
  assert v.hasErrors == false
```

## requiredWith
Validates that the field is present and not empty if any of the other specified fields are present.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abc"
  assert context.params.getStr("other") == "123"
  v.requiredWith("base", ["a"])
  v.requiredWith("base", ["other"])
  assert v.hasErrors == false
```

## requiredWithAll
Validates that the field is present and not empty if all of the other specified fields are present.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abc"
  assert context.params.getStr("empty") == ""
  assert context.params.getStr("other1") == "123"
  assert context.params.getStr("other2") == "123"
  v.requiredWithAll("valid", ["other1", "other2"])
  v.requiredWithAll("empty", ["notExists"])
  assert v.hasErrors == false
```

## requiredWithout
Validates that the field is present and not empty if any of the other specified fields are not present.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abc"
  assert context.params.getStr("empty") == ""
  assert context.params.getStr("other") == "123"
  v.requiredWithout("base", ["aaa", "bbb"])
  v.requiredWithout("empty", ["other"])
  assert v.hasErrors == false
```

## requiredWithoutAll
Validates that the field is present and not empty if none of the other specified fields are present.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abc"
  assert context.params.getStr("empty") == ""
  assert context.params.getStr("other") == "123"
  v.requiredWithoutAll("base", ["aaa", "bbb"])
  v.requiredWithoutAll("empty", ["other"])
  assert v.hasErrors == false
```

## same
Validates that the field's value is the same as the specified field's value.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abc"
  assert context.params.getStr("target") == "abc"
  v.same("base", "target")
  assert v.hasErrors == false
```

## sizeNum
Validates that the field's value is the specified size. For numeric values, the value must be an integer.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getInt("base") == 2
  v.sizeNum("base", 2)
  assert v.hasErrors == false
```

## sizeFile
Validates that the field's file size is the specified size in kilobytes.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base").len == 2048
  v.sizeFile("base", 2)
  assert v.hasErrors == false
```

## sizeStr
Validates that the field's value is the specified length.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "ab"
  v.sizeStr("base", 2)
  assert v.hasErrors == false
```

## sizeArr
Validates that the field's array length is the specified size.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a, b"
  v.sizeArr("base", 2)
  assert v.hasErrors == false
```

## startsWith
Validates that the field's value starts with one of the specified values.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "abcde"
  v.startsWith("base", ["abc", "bcd"])
  assert v.hasErrors == false
```

## timestamp
Validates that the field's value is a valid timestamp.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "1577804400"
  v.timestamp("base")
  assert v.hasErrors == false
```

## url
Validates that the field's value is a valid URL.
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "https://google.com:8000/xxx/yyy/zzz?key=value"
  v.url("base")
  assert v.hasErrors == false
```

## uuid
Validates that the field's value is a valid universally unique identifier (UUID) as specified in RFC 4122 (versions 1, 3, 4, 5).
```nim
proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(context)
  assert context.params.getStr("base") == "a0a2a2d2-0b87-4a18-83f2-2529882be2de"
  v.uuid("base")
  assert v.hasErrors == false
```
