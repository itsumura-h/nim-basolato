Validation
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [Validation](#validation)
   * [Simple Validation](#simple-validation)
      * [Sample](#sample)
   * [Request Validation](#request-validation)
         * [API](#api)
      * [Sample](#sample-1)
   * [Error messages](#error-messages)
      * [Locale](#locale)
      * [Replace key name](#replace-key-name)
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
      * [ltArr](#ltarr)
      * [lteNum](#ltenum)
      * [lteFile](#ltefile)
      * [lteStr](#ltestr)
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

<!-- Added by: root, at: Sat Sep 18 06:54:44 UTC 2021 -->

<!--te-->

Basolato has it's own validation function. It recieves request and check request params.  
There are two validation type. One is used in controller that recieve request and return errors array.  
Another is more simple. Recieve value and return `bool`.

# Simple Validation
```
import basolato/core/validation
```
## Sample
```nim
echo newValidation().email("sample@example.com")
>> true

echo newValidation().email("sample@example")
>> false
```

# Request Validation
```
import basolato/request_validation
```
### API
```nim
proc newRequestValidation*(params: Params):RequestValidation =

proc hasErrors*(self:RequestValidation):bool =

proc hasError*(self:RequestValidation, key:string):bool =

proc errors*(self:RequestValidation):ValidationErrors =

proc add*(self:ValidationErrors, key, value:string) =

proc storeValidationResult*(client:Client, validation:RequestValidation) {.async.} =
```
`storeValidationResult` stores params and validation errors to session as flash message.

## Sample
form request
```html
<input type="base" name="email" value="user1@example.com">
```
or json request
```json
{
  "email": "user1@example.com"
}
```

```nim
proc signUp*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  v.required("email")
  v.email("email")
  let client = await newClient(request)
  if v.hasErrors:
    await client.storeValidationResult(v)
    return redirect("/signup")
```
```nim
let client = await newClient(request)
echo await client.getFlash()
>> {
  "errors": {
    "email": ["The name field is required."]
  },
  "params": {
    "email": "user1@example.com"
  }
}
```

# Error messages
## Locale
Definition of error messages is in `resources/lang/{locale}/validation.json`.  
Default local is `en`. If you want to replace it, please define environment valiable `LOCALE`.

## Replace key name
Error message has request params key name by default. You can replace it.

default
```nim
let v = newRequestValidation(params)
v.required("name")
v.errors["name"][0] == "The name field is required."
```

replace
```nim
let v = newRequestValidation(params)
v.required("name", attribute="User Name")
v.errors["name"][0] == "The User Name field is required."
```

# Rules
See test code of [simple validation](../../tests/test_validation.nim) and [request validation](../../tests/test_request_validation.nim)

## accepted
The field under validation must be "yes", "on", 1, or true. This is useful for validating "Terms of Service" acceptance or similar fields.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "on"
  v.accepted("base")
  assert v.hasErrors == false
```

## after
The field under validation must be a value after a given date.  
Instead of passing a date string to be evaluated by `format`, you may specify another field to compare against the `Datetime`
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "2020-01-01"
  assert params.getStr("target") == "2020-01-02"
  v.after("base", "target", "yyyy-MM-dd")
  v.after("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  assert v.hasErrors == false
```

## afterOrEqual
The field under validation must be a value after or equal to the given date.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "2020-01-01"
  assert params.getStr("same") == "2020-01-01"
  assert params.getStr("target") == "2020-01-02"
  v.afterOrEqual("base", "target", "yyyy-MM-dd")
  v.afterOrEqual("base", "same", "yyyy-MM-dd")
  v.afterOrEqual("base", "2020-01-01".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  v.afterOrEqual("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  assert v.hasErrors == false
```

## alpha
The field under validation must be entirely alphabetic characters.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("small") == "abcdefghijklmnopqrstuvwxyz"
  assert params.getStr("large") == "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  v.alpha("small")
  v.alpha("large")
  assert v.hasErrors == false
```

## alphaDash
The field under validation may have alpha-numeric characters, as well as dashes and underscores.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abcABC012-_"
  v.alphaDash("base")
  assert v.hasErrors == false
```

## alphaNum
The field under validation must be entirely alpha-numeric characters.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abcABC012"
  v.alphaNum("base")
  assert v.hasErrors == false
```

## array
The field under validation must be a `array`.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a, b, c"
  v.array("base")
  assert v.hasErrors == false
```

## before
The field under validation must be a value preceding the given date.  
In addition, like the `after` rule, the name of another field under validation may be supplied as the value of `Datetime`.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "2020-01-02"
  assert params.getStr("target") == "2020-01-01"
  v.before("base", "target", "yyyy-MM-dd")
  v.before("base", "2020-01-01".parse("yyyy-MM-dd")", "yyyy-MM-dd")
  assert v.hasErrors == false
```

## beforeOrEqual
The field under validation must be a value preceding or equal the given date.  
In addition, like the `after` rule, the name of another field under validation may be supplied as the value of `Datetime`.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "2020-01-02"
  assert params.getStr("same") == "2020-01-02"
  assert params.getStr("target") == "2020-01-01"
  v.beforeOrEqual("base", "target", "yyyy-MM-dd")
  v.beforeOrEqual("base", "same", "yyyy-MM-dd")
  v.beforeOrEqual("base", "2020-01-01".parse("yyyy-MM-dd")", "yyyy-MM-dd")
  v.beforeOrEqual("base", "2020-01-02".parse("yyyy-MM-dd")", "yyyy-MM-dd")
  assert v.hasErrors == false
```

## betweenNum
The field under validation must be between the given min and max.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getInt("int") == 2
  assert params.getFloat("float") == 2.0
  v.betweenNum("int", 1, 3)
  v.betweenNum("float", 1.9, 2.1)
  assert v.hasErrors == false
```

## betweenStr
The field under validation must have a length between the given min and max.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("str") == "ab"
  v.betweenStr("str", 1, 3)
  assert v.hasErrors == false
```

## betweenArr
The field under validation must have a length between the given min and max.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("arr") == "a, b"
  v.betweenStr("arr", 1, 3)
  assert v.hasErrors == false
```

## betweenFile
The field under validation must have a size between the given min and max.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("file").len == 2048
  v.betweenFile("file", 1, 3)
  assert v.hasErrors == false
```

## boolean
The field under validation must be able to be cast as a boolean.  
Accepted input are `y, yes, true, 1, on, n, no, false, 0, off`
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("bool") == "true"
  v.boolean("bool")
  assert v.hasErrors == false
```

## confirmed
The field under validation must have a matching field of `{field}_confirmation`. For example, if the field under validation is `password`, a matching `password_confirmation` field must be present in the input.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("password") == "aaa"
  assert params.getStr("password_confirmation") == "aaa"
  assert params.getStr("password_check") == "aaa"
  v.confirmed("password")
  v.confirmed("password", saffix="_check")
  assert v.hasErrors == false
```

## date
The field under validation must be a valid, non-relative `Datetime`
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "2020-01-01"
  v.date("base", "yyyy-MM-dd")
  assert v.hasErrors == false
```

## dateEquals
The field under validation must be equal to the given `Datetime`.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("date") == "2020-01-01"
  assert params.getStr("timestamp") == "1577880000"
  let target = "2020-01-01".format("yyyy-MM-dd")
  v.dateEquals("base", "yyyy-MM-dd", target)
  v.dateEquals("timestamp", target)
  assert v.hasErrors == false
```

## different
The field under validation must have a different value than `arge2`.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a"
  assert params.getStr("target") == "b"
  v.different("base", "target")
  assert v.hasErrors == false
```

## digits
The field under validation must be numeric and must have an exact length of `arge2`.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "10"
  v.digits("base", 2)
  assert v.hasErrors == false
```

## digitsBetween
The field under validation must be numeric and must have a length between the given min and max.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "10"
  v.digitsBetween("base", 1, 3)
  assert v.hasErrors == false
```

## distinctArr
When validating arrays, the field under validation must not have any duplicate values.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a, b, c"
  v.distinctArr("base")
  assert v.hasErrors == false
```

## domain
The field under validation must have a valid A or AAAA record.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("v4") == "domain.com"
  assert params.getStr("v6") == "[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]"
  v.domain("v4")
  v.domain("v6")
  assert v.hasErrors == false
```

## email
The field under validation must be formatted as an email address.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "email@domain.com"
  v.email("base")
  assert v.hasErrors == false
```

## endsWith
The field under validation must end with one of the given values.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abcdefg"
  v.email("base", ["ef", "fg"])
  assert v.hasErrors == false
```

## file
The field under validation must be a successfully uploaded file.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params["base"].ext == "jpg"
  v.file("base")
  assert v.hasErrors == false
```

## filled
The field under validation must not be empty when it is present.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a"
  v.filled("base")
  assert v.hasErrors == false
```

## gtNum
The field under validation must be greater than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getInt("base") == 2
  assert params.getInt("target") == 1
  v.gtFile("base", "target")
  assert v.hasErrors == false
```

## gtFile
The field under validation must have a greater size than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base").len == 2048
  assert params["base"].ext == "jpg"
  assert params.getStr("target").len == 1024
  assert params["target"].ext == "jpg"
  v.gtFile("base", "target")
  assert v.hasErrors == false
```

## gtStr
The field under validation must be longer than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "ab"
  assert params.getStr("target") == "a"
  v.gtStr("base", "target")
  assert v.hasErrors == false
```

## gtArr
The field under validation must have more items than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a, b"
  assert params.getStr("target") == "a"
  v.gtArr("base", "target")
  assert v.hasErrors == false
```

## gteNum
The field under validation must be same or greater than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getInt("base") == 2
  assert params.getInt("same") == 2
  assert params.getInt("target") == 1
  v.gtFile("base", "target")
  v.gtFile("base", "same")
  assert v.hasErrors == false
```

## gteFile
The field under validation must be have a greater or same size than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base").len == 2048
  assert params.getStr("same").len == 2048
  assert params.getStr("target").len == 1024
  v.gteFile("base", "target")
  v.gteFile("base", "same")
  assert v.hasErrors == false
```

## gteStr
The field under validation must be have longer or same than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "ab"
  assert params.getStr("same") == "bc"
  assert params.getStr("target") == "a"
  v.gteStr("base", "target")
  v.gteStr("base", "same")
  assert v.hasErrors == false
```

## gteArr
The field under validation must have more or same items than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a, b"
  assert params.getStr("same") == "b, c"
  assert params.getStr("target") == "a"
  v.gteArr("base", "target")
  v.gteArr("base", "same")
  assert v.hasErrors == false
```

## image
The file under validation must be an image (jpg, jpeg, png, bmp, gif, svg, or webp).
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params["base"].ext == "jpg"
  v.image("base")
  assert v.hasErrors == false
```

## in
The field under validation must be included in the given list of values.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params["base"].ext == "a"
  v.in("base", ["a", "b"])
  assert v.hasErrors == false
```

## inArray
The field under validation must be in anotherfield's values.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a"
  assert params.getStr("target") == "a, b, c"
  v.inArray("base", "target")
  assert v.hasErrors == false
```

## integer
The field under validation must be an integer.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getInt("base") == 1
  v.integer("base")
  assert v.hasErrors == false
```

## json
The field under validation must be a valid JSON string.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == """{"key": "value"}"""
  v.json("base")
  assert v.hasErrors == false
```

## ltNum
The field under validation must be less than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getInt("base") == 1
  assert params.getInt("target") == 2
  v.ltNum("base", "target")
  assert v.hasErrors == false
```

## ltFile
The field under validation must have less size than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base").len == 1024
  assert params.getStr("target").len == 2048
  v.ltFile("base", "target")
  assert v.hasErrors == false
```

## ltStr
The field under validation must have less length than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a"
  assert params.getStr("target") == "ab"
  v.ltStr("base", "target")
  assert v.hasErrors == false
```

## ltArr
The field under validation must have less items than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a"
  assert params.getStr("target") == "a, b"
  v.ltStr("base", "target")
  assert v.hasErrors == false
```

## lteNum
The field under validation must be less than or same the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getInt("base") == 1
  assert params.getInt("same") == 1
  assert params.getInt("target") == 2
  v.ltNum("base", "target")
  v.ltNum("base", "same")
  assert v.hasErrors == false
```

## lteFile
The field under validation must have less size than or same size the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base").len == 1024
  assert params.getStr("same").len == 1024
  assert params.getStr("target").len == 2048
  v.lteFile("base", "target")
  v.lteFile("base", "same")
  assert v.hasErrors == false
```

## lteStr
The field under validation must have less length than  or same length the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a"
  assert params.getStr("same") == "b"
  assert params.getStr("target") == "ab"
  v.lteStr("base", "target")
  v.lteStr("base", "same")
  assert v.hasErrors == false
```

## ltArr
The field under validation must have less or same items than the given field.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base").len == "a"
  assert params.getStr("same").len == "a"
  assert params.getStr("target").len == "a, b"
  v.ltStr("base", "target")
  v.ltStr("base", "same")
  assert v.hasErrors == false
```

## maxNum
The field under validation must be less than or equal to a maximum value.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getInt("base") == 2
  assert params.getInt("small") == 1
  v.maxNum("base", 2)
  v.maxNum("small", 2)
  assert v.hasErrors == false
```

## maxFile
The field under validation must be less size than or equal to a maximum value.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base").len == 2048
  assert params.getStr("small").len == 1024
  v.maxFile("base", 2)
  v.maxFile("small", 2)
  assert v.hasErrors == false
```

## maxStr
The field under validation must be less length than or equal to a maximum value.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "ab"
  assert params.getStr("small") == "a"
  v.maxStr("base", 2)
  v.maxStr("small", 2)
  assert v.hasErrors == false
```

## maxArr
The field under validation must be less length than or equal to a maximum value.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a, b"
  assert params.getStr("small") == "a"
  v.maxArr("base", 2)
  v.maxArr("small", 2)
  assert v.hasErrors == false
```

## mimes
The file under validation must have a MIME type corresponding to one of the listed extensions.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params["base"].ext == "jpg"
  v.mimes("base", ["jpg", "gif"])
  assert v.hasErrors == false
```

## minNum
The field under validation must have a minimum value.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getInt("base") == 2
  v.minNum("base", 1)
  v.minNum("base", 2)
  assert v.hasErrors == false
```

## minFile
The field under validation must have a minimum value of size.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base").len == 2048
  v.minFile("base", 1)
  v.minFile("base", 2)
  assert v.hasErrors == false
```

## minStr
The field under validation must have a minimum value of length.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "ab"
  v.minStr("base", 1)
  v.minStr("base", 2)
  assert v.hasErrors == false
```

## minArr
The field under validation must have a minimum value of length.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a, b"
  v.minArr("base", 1)
  v.minArr("base", 2)
  assert v.hasErrors == false
```

## notIn
The field under validation must not be included in the given list of values.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a"
  v.notIn("base", ["b", "c"])
  assert v.hasErrors == false
```

## notRegex
The field under validation must not match the given regular expression.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abc"
  v.notRegex("base", re"\d")
  assert v.hasErrors == false
```

## numeric
The field under validation must be `numeric`.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getInt("base") == 1
  assert params.getFloat("float") == -1.23
  v.numeric("base")
  v.numeric("float")
  assert v.hasErrors == false
```

## present
The field under validation must be present in the input data but can be empty.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == ""
  v.present("base")
  assert v.hasErrors == false
```

## regex
The field under validation must match the given regular expression.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abc"
  v.regex("base", re"\w")
  assert v.hasErrors == false
```

## required
The field under validation must be present in the input data and not empty. A field is considered "empty" if one of the following conditions are true:
- The value is `null`.
- The value is an empty string.
- The value is an empty array or empty `Countable` object.
- The value is an uploaded file with no path.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abc"
  v.required("base")
  assert v.hasErrors == false
```

## requiredIf
The field under validation must be present and not empty if the anotherfield field is equal to any value.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("empty") == ""
  assert params.getStr("other") == "123"
  v.requiredIf("base", "other", ["123"])
  v.requiredIf("empty", "other", ["xyz"])
  assert v.hasErrors == false
```

## requiredUnless
The field under validation must be present and not empty unless the anotherfield field is equal to any value.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("empty") == ""
  assert params.getStr("other") == "123"
  v.requiredUnless("base", "other", ["123"])
  v.requiredUnless("empty", "other", ["123"])
  assert v.hasErrors == false
```

## requiredWith
The field under validation must be present and not empty only if any of the other specified fields are present and not empty.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("other") == "123"
  v.requiredWith("base", ["a"])
  v.requiredWith("base", ["other"])
  assert v.hasErrors == false
```

## requiredWithAll
The field under validation must be present and not empty only if all of the other specified fields are present and not empty.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("empty") == ""
  assert params.getStr("other1") == "123"
  assert params.getStr("other2") == "123"
  v.requiredWithAll("valid", ["other1", "other2"])
  v.requiredWithAll("empty", ["notExists"])
  assert v.hasErrors == false
```

## requiredWithout
The field under validation must be present and not empty only when any of the other specified fields are empty or not present.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("empty") == ""
  assert params.getStr("other") == "123"
  v.requiredWithoutAll("base", ["aaa", "bbb"])
  v.requiredWithoutAll("empty", ["other"])
  assert v.hasErrors == false
```

## same
The given field must match the field under validation.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("target") == "abc"
  v.same("base", "target")
  assert v.hasErrors == false
```

## sizeNum
The field under validation must have a size matching the given value. For numeric data, value corresponds to a given integer value (the attribute must also have the numeric or integer rule).
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getInt("base") == 2
  v.sizeNum("base", 2)
  assert v.hasErrors == false
```

## sizeFile
The field under validation must have a size matching the given value. For files, size corresponds to the file size in kilobytes.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base").len == 2048
  v.sizeFile("base", 2)
  assert v.hasErrors == false
```

## sizeStr
The field under validation must have a size matching the given value.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "ab"
  v.sizeStr("base", 2)
  assert v.hasErrors == false
```

## sizeArr
The field under validation must have a size matching the given value.  For an array, size corresponds to the length of the array.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a, b"
  v.sizeArr("base", 2)
  assert v.hasErrors == false
```

## startsWith
The field under validation must start with one of the given values.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "abcde"
  v.startsWith("base", ["abc", "bcd"])
  assert v.hasErrors == false
```

## timestamp
The field under validation must be a valid timestamp.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "1577804400"
  v.timestamp("base")
  assert v.hasErrors == false
```

## url
The field under validation must be a valid URL.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "https://google.com:8000/xxx/yyy/zzz?key=value"
  v.url("base")
  assert v.hasErrors == false
```

## uuid
The field under validation must be a valid RFC 4122 (version 1, 3, 4, or 5) universally unique identifier (UUID).
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  assert params.getStr("base") == "a0a2a2d2-0b87-4a18-83f2-2529882be2de"
  v.url("base")
  assert v.hasErrors == false
```
