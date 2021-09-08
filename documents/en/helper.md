Healper
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [Healper](#healper)
      * [dd](#dd)
         * [API](#api)
         * [Example](#example)
      * [password](#password)
         * [API](#api-1)
         * [Example](#example-1)

<!-- Added by: root, at: Wed Sep  8 16:11:21 UTC 2021 -->

<!--te-->

## dd
`dd()` is essentially adding a break point in your code which dumps the properties of an object to your browser.  
This proc is only available in develop mode.

### API
```
proc dd(outputs:varges[string, `$`])
```

### Example
```nim
var a = %*{
  "key1": "value1",
  "key2": "value2",
  "key3": "value3",
  "key4": "value4",
}
dd(a, "abc", request.repr)
```

![dd](../images/helper-dd.jpg)

## password

Basolato has its own useful password library. It uses `bcrypt` package inside.  
https://github.com/runvnc/bcryptnim

### API
```nim
proc genHashedPassword*(val:string):string =

proc isMatchPassword*(input, hashedPassword:string):bool =
```

### Example
```nim
import basolato/password

let pass1 = "Password!"
let pass2 = "Password!"
let pass3 = "WrongPassword"
let hashed = genHashedPassword(pass1)

echo isMatchPassword(pass2, hashed)
>> true

echo isMatchPassword(pass3, hashed)
>> false
```
