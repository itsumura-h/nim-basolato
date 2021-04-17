Validation
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [Validation](#validation)
   * [Simple Validation](#simple-validation)
      * [Sample](#sample)
   * [Request Validation](#request-validation)
      * [Sample](#sample-1)
   * [Error messages language](#error-messages-language)
         * [accepted](#accepted)
         * [domain](#domain)
         * [strictEmail](#strictemail)
         * [equals](#equals)
         * [gratorThan](#gratorthan)
         * [inRange](#inrange)
         * [ip](#ip)
         * [lessThan](#lessthan)
         * [numeric](#numeric)
         * [password](#password)
   * [Request Validation](#request-validation-1)
      * [sample](#sample-2)
      * [Custom Validation](#custom-validation)
      * [Available Rules](#available-rules)
         * [accepted](#accepted-1)
         * [contains](#contains)
         * [email, strictEmail](#email-strictemail)
         * [equals](#equals-1)
         * [exists](#exists)
         * [gratorThan](#gratorthan-1)
         * [inRange](#inrange-1)
         * [ip](#ip-1)
         * [isIn](#isin)
         * [lessThan](#lessthan-1)
         * [numeric](#numeric-1)
         * [oneOf](#oneof)
         * [password](#password-1)
         * [required](#required)
         * [unique](#unique)

<!-- Added by: root, at: Mon Apr 12 07:19:28 UTC 2021 -->

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
func newRequestValidation*(params: Params):RequestValidation =

func hasErrors*(self:RequestValidation):bool =

func hasError*(self:RequestValidation, key:string):bool =

func errors*(self:RequestValidation):ValidationErrors =

func add*(self:ValidationErrors, key, value:string) =

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
echo Validation().domain("example.com")
>> true

echo Validation().domain("example")
>> false
```

### strictEmail
```nim
echo Validation().strictEmail("sample@example.com")
>> true

echo Validation().strictEmail("sample@example")
>> false
```

### equals
```nim
echo Validation().equals("a", "a")
>> true

echo Validation().equals(1, 2)
>> false
```

### gratorThan
```nim
echo Validation().gratorThan(1.2, 1.1)
>> true

echo Validation().gratorThan(3, 2)
>> false
```

### inRange
```nim
echo Validation().inRange(2, 1, 3)
>> true

echo Validation().gratorThan(1.5, 1, 1.4)
>> false
```

### ip
```nim
echo Validation().ip("12.0.0.1")
>> true

echo Validation().ip("255.255.255.256")
>> false
```

### lessThan
```nim
echo Validation().lessThan(1.1, 1.2)
>> true

echo Validation().lessThan(3, 2)
>> false
```

### numeric
```nim
echo Validation().numeric("1")
>> true

echo Validation().numeric("a")
>> false
```

### password
```nim
echo Validation().password("Password1")
>> true

echo Validation().password("pass")
>> false
```


# Request Validation
```
import basolato/request_validation
```

## sample

Controller
```nim
import json
import basolato/controller

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  var v = newValidation(params)
  v.required(["name", "email", "password"])
  v.strictEmail("email")
  v.password("password")
  try:
    v.valid()
    let name = params.getStr("name")
    let email = params.getStr("email")
    let password = params.getStr("password")

    let usecase = newSignInUsecase()
    usecase.signin(name, email, password)
    return redirect("/")
  except:
    return render(createView(name, email, v.errors))
```

View
```html
import json

proc createViewImpl(name:string, email:string, errors:JsonNode): string = tmpli html"""
  <form method="post">
    $(csrfToken())
    <div>
      <p>name</p>
      $if errors.hasKey("name") {
        <ul>
          $for error in errors["name"] {
            <li>$error</li>
          }
        </ul>
      }
      <p><input type="base" value="$(old(error, "name"))" name="name"></p>
    </div>
    .
    .
    .
```

## Custom Validation
You can also create your own validation middleware. It should recieve `RequestValidation` object and return it.  
`putValidate()` proc is useful to create/add error in `RequestValidation` object.

middleware/custom_validate_middleware.nim
```nim
import json, tables
import bcrypt
import allographer/query_builder
import basolato/request_validation

proc checkPassword*(self:RequestValidation, key:string): RequestValidation =
  let password = self.params["password"]
  let response = RDB().table("users")
                  .select("password")
                  .where("email", "=", self.params["email"])
                  .first()
  let dbPass = if response.kind != JNull: response["password"].getStr else: ""
  let hash = dbPass.substr(0, 28)
  let hashed = hash(password, hash)
  let isMatch = compare(hashed, dbPass)
  if not isMatch:
    self.putValidate(key, "password is not match")
  return self
```

## Available Rules

### accepted
This will add errors if not checked in checkbox. Default checked value is `on` and if you want overwrite it, set in arg.

```html
<input type="checkbox" name="sample">
>> If it checked, it return {"sample", "on"}

<input type="checkbox" name="sample2" value="checked">
>> If it checked, it return {"sample2", "checked"}
```

```nim
var v = validate(request)
v.accepted("sample")
v.accepted("sample2", "checked")
```

### contains
This will add errors if value in request doesn't contain a expected string.

```json
{"email": "user1@gmail.com"}
```

```nim
var v = validate(request)
v.contains("email", "user")
```

### email, strictEmail
This will add errors if value is not match a style of email address.  
`strictEmail` supports [RFC5321](https://tools.ietf.org/html/rfc5321) and [RFC5322](https://tools.ietf.org/html/rfc5322) completely. References this Python code https://gist.github.com/frodo821/681869a36148b5214632166e0ad293a9  

Original articles
[メイルアドレス正規表現ふたたび](https://www.nslabs.jp/email-address-regular-expression.rhtml)  
[正規表現でのメールアドレスチェックは見直すべき – ReDoS](https://blog.ohgaki.net/redos-must-review-mail-address-validation)


```json
{"address": "user1@gmail.com"}
```

```nim
var v = validate(request)
v.email("address")
v.strictEmail("address")
```

### equals
This will add errors if value is not same against expectd string.

```json
{"name": "John"}
```

```nim
var v = validate(request)
v.equals("name", "John")
```

### exists
This will add errors if key is not exist in request params.

```json
{"name": "John", "email": "John@gmail.com"}
```

```nim
var v = validate(request)
v.exists("name")
```

### gratorThan
This will add errors if value is not grater/larger than expected value.

```json
{"age": "25"}
```

```nim
var v = validate(request)
v.gratorThan("age", 26)
```

### inRange
This will add errors if value is not in rage of expected value.

```json
{"age": "25"}
```

```nim
var v = validate(request)
v.inRange("age", min=20, max=60)
```

### ip
This will add errors if value is not match a style of IP address.

```json
{"ip_address": "127.0.0.1"}
```

```nim
var v = validate(request)
v.ip("ip_address")
```

### isIn
This will add errors if value is not match for one of expected values.

```json
{"name": "John"}
```

```nim
var v = validate(request)
v.isIn("name", ["John", "Paul", "George", "Ringo"])
```

### lessThan
This will add errors if value is not less/smaller than expected value.

```json
{"age": "25"}
```

```nim
var v = validate(request)
v.gratorThan("age", 24)
```


### numeric
This will add errors if value is not number.

```json
{"num": 36.2}
```

```nim
var v = validate(request)
v.numeric("num")
```

### oneOf
This will add errors if one of expected keys is not present in request.

```json
{"name": "John", "email": "John@gmail.com"}
```

```nim
var v = validate(request)
v.oneOf(["name", "birth_date", "job"])
```

### password
This will add errors if value is not match a style of password.  
It needs at least 8 chars, one upper and lower letter, symbol(ex: @-_?!) is available.

```json
{"pass": "Password1!"}
```

```nim
var v = validate(request)
v.password("pass")
```

### required
This will add errors if all of expected keys is not present in request.

```json
{"name": "John", "email": "John@gmail.com"}
```

```nim
var v = validate(request)
v.required(["name", "email"])
```

### unique
This will add errors if expected value is not unique in database.

table: users

|id|name|email|
|---|---|---|
|1|user1|user1@gmail.com|
|2|user2|user2@gmail.com|
|3|user3|user3@gmail.com|
|4|user4|user4@gmail.com|

```json
{"mail": "user5@gmail.com"}
```

```nim
var v = validate(request)
v.unique("mail", "users", "email")
```
|arg position|example|content|
|---|---|---|
|1|"mail"|response params key|
|2|"users"|RDB table name|
|3|"email"|RDB column name|
