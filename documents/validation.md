Validation
===
[back](../README.md)

Table of Contents

<!--ts-->
<!--te-->

Basolato has it's own validation function. It recieves request and check request params.

## sample

Controller
```nim
type SignUpController = ref object
  request:Request
  auth: Auth

proc newSignUpController*(request:Request): SignUpController =
  return SignUpController(
    request: request,
    auth: initAuth(request)
  )

proc store*(this:SignUpController): Response =
  let name = this.request.params["name"]
  let email = this.request.params["email"]
  let password = this.request.params["password"]
  # validation
  let v = this.request.validate()
            .required(["name", "email", "password"])
            .email("email")
            .unique("email", "users", "email")
            .password("password")
  if v.errors.len > 0:
    return render(createHtml(this.auth, name, email, v.errors))
```

View
```html
proc createHtmlImpl(name:string, email:string, errors:JsonNode): string = tmpli html"""
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
      <p><input type="text" value="$name" name="name"></p>
    </div>
    .
    .
    .
```

## Custom Validation
You can also create your own validation middleware. It should recieve `Validation` object and return it.  
`putValidate()` proc is useful to create/add error in `Validation` object.

middleware/custom_validate_middleware.nim
```nim
import json, tables
import bcrypt
import allographer/query_builder
import basolato/validation

proc checkPassword*(this:Validation, key:string): Validation =
  let password = this.params["password"]
  let response = RDB().table("users")
                  .select("password")
                  .where("email", "=", this.params["email"])
                  .first()
  let dbPass = if response.kind != JNull: response["password"].getStr else: ""
  let hash = dbPass.substr(0, 28)
  let hashed = hash(password, hash)
  let isMatch = compare(hashed, dbPass)
  if not isMatch:
    this.putValidate(key, "password is not match")
  return this
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
validate()
  .accepted("sample")
  .accepted("sample2", "checked")
```

### contains
This will add errors if value in request doesn't contain a expected string.

```json
{"email": "user1@gmail.com"}
```

```nim
validate().contains("email", "user")
```

### email, strictEmail
This will add errors if value is not match a style of email address.  
`strictEmail` supports [RFC5321](https://tools.ietf.org/html/rfc5321) and [RFC5322](https://tools.ietf.org/html/rfc5322) completely. References this Python code https://gist.github.com/frodo821/681869a36148b5214632166e0ad293a9

```json
{"address": "user1@gmail.com"}
```

```nim
validate().email("address")
validate().strictEmail("address")
```

### equals
This will add errors if value is not same against expectd string.

```json
{"name": "John"}
```

```nim
validate().equals("name", "John")
```

### exists
This will add errors if key is not exist in request params.

```json
{"name": "John", "email": "John@gmail.com"}
```

```nim
validate().exists("name")
```

### gratorThan
This will add errors if value is not grater/larger than expected value.

```json
{"age": "25"}
```

```nim
validate().gratorThan("age", 26)
```

### inRange
This will add errors if value is not in rage of expected value.

```json
{"age": "25"}
```

```nim
validate().inRange("age", min=20, max=60)
```

### ip
This will add errors if value is not match a style of IP address.

```json
{"ip_address": "127.0.0.1"}
```

```nim
validate().ip("ip_address")
```

### isIn
This will add errors if value is not match for one of expected values.

```json
{"name": "John"}
```

```nim
validate().isIn("name", ["John", "Paul", "George", "Ringo"])
```

### lessThan
This will add errors if value is not less/smaller than expected value.

```json
{"age": "25"}
```

```nim
validate().gratorThan("age", 24)
```


### numeric
This will add errors if value is not number.

```json
{"num": 36.2}
```

```nim
validate().numeric("num")
```

### oneOf
This will add errors if one of expected keys is not present in request.

```json
{"name": "John", "email": "John@gmail.com"}
```

```nim
validate().oneOf(["name", "birth_date", "job"])
```

### password
This will add errors if value is not match a style of password.  
It needs at least 8 chars, one upper and lower letter, symbol(ex: @-_?!) is available.

```json
{"pass": "Password1!"}
```

```nim
validate().password("pass")
```

### required
This will add errors if all of expected keys is not present in request.

```json
{"name": "John", "email": "John@gmail.com"}
```

```nim
validate().required(["name", "email"])
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
validate().unique("mail", "users", "email")
```
|arg position|example|content|
|---|---|---|
|1|"mail"|response params key|
|2|"users"|RDB table name|
|3|"email"|RDB column name|
