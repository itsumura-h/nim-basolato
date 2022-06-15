ヘルパー関数
===
[戻る](../../README.md)

目次
<!--ts-->
   * [ヘルパー関数](#ヘルパー関数)
      * [dd](#dd)
         * [API](#api)
         * [サンプル](#サンプル)
      * [password](#password)
         * [API](#api-1)
         * [サンプル](#サンプル-1)

<!-- Added by: root, at: Wed Jun 15 11:35:14 UTC 2022 -->

<!--te-->

## dd
`dd`関数はソースコードの中にブレークポイントを発生させ、引数に入れている変数をブラウザに表示させます。
この機能は開発環境でのみ有効になります。

### API
```
proc dd(outputs:varges[string, `$`])
```


### サンプル
```nim
var a = %*{
  "key1": "value1",
  "key2": "value2",
  "key3": "value3",
  "key4": "value4",
}
dd(a,　"abc", request.repr)
```

![dd](../images/helper-dd.jpg)

## password

Basolatoは内部で`bcrypt`を使った、便利なパスワードライブラリを持っています。  
https://github.com/runvnc/bcryptnim

### API
```nim
proc genHashedPassword*(val:string):string =

proc isMatchPassword*(input, hashedPassword:string):bool =
```

### サンプル
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
