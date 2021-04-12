Password
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [Password](#password)
      * [API](#api)
      * [サンプル](#サンプル)

<!-- Added by: root, at: Mon Apr 12 06:16:59 UTC 2021 -->

<!--te-->

Basolatoは`bcrpt`を使った便利なパスワードライブラリがあります。
https://github.com/runvnc/bcryptnim

## API
```nim
proc genHashedPassword*(val:string):string =

proc isMatchPassword*(input, hashedPassword:string):bool =
```

## サンプル
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
