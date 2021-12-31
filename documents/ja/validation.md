バリデーション
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [バリデーション](#バリデーション)
   * [シンプルなバリデーション](#シンプルなバリデーション)
      * [サンプル](#サンプル)
   * [リクエストバリデーション](#リクエストバリデーション)
         * [API](#api)
      * [サンプル](#サンプル-1)
   * [エラーメッセージ](#エラーメッセージ)
      * [ロケール](#ロケール)
      * [リクエストパラメータのキー名の差し替え](#リクエストパラメータのキー名の差し替え)
   * [ルール](#ルール)
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

<!-- Added by: root, at: Fri Dec 31 11:50:55 UTC 2021 -->

<!--te-->

Basolatoは、独自のバリデーション機能を持っています。この機能は、リクエストを受け取り、リクエストパラメータをチェックします。  
バリデーションには2つのタイプがあります。一つは、リクエストを受け取って、エラーの配列を返すコントローラで使われます。  
もう一つはもっとシンプルなものです。値を受け取って `bool` を返すものです。

# シンプルなバリデーション
```
import basolato/core/validation
```
## サンプル
```nim
echo newValidation().email("sample@example.com")
>> true

echo newValidation().email("sample@example")
>> false
```

# リクエストバリデーション
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
`storeValidationResult`はリクエストパラメータとバリデーション結果のエラーメッセージをフラッシュメッセージとしてセッションに保存します。

## サンプル
フォームリクエスト
```html
<input type="base" name="email" value="user1@example.com">
```
JSONリクエスト
```json
{
  "email": "user1@example.com"
}
```
```nim
proc signUp*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
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
# エラーメッセージ
## ロケール
エラーメッセージの定義は `resources/lang/{locale}/validation.json` にあります。 
デフォルトのロケールは `en` です。これを置き換えたい場合には、環境変数 `LOCALE` を定義してください。

## リクエストパラメータのキー名の差し替え
エラーメッセージにはデフォルトでrequest paramsのキー名が入っています。`attribute`を指定することで置き換えることができます。

初期状態
```nim
let v = RequestValidation.new(params)
v.required("name")
v.errors["name"][0] == "The name field is required."
```

置き換え
```nim
let v = RequestValidation.new(params)
v.required("name", attribute="User Name")
v.errors["name"][0] == "The User Name field is required."
```

# ルール
[シンプルバリデーション](../../tests/test_validation.nim)、[リクエストバリデーション](../../tests/test_request_validation.nim)のテストコードも参考にしてください。

## accepted
そのフィールドがyes、on、1、trueであることをバリデートします。これは「サービス利用規約」同意のバリデーションに便利です。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "on"
  v.accepted("base")
  assert v.hasErrors == false
```

## after
フィールドの値が与えられた日付より後であるかバリデーションします。  
`Datetime`型と、比較する別のフィールド名を指定することができます。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "2020-01-01"
  assert params.getStr("target") == "2020-01-02"
  v.after("base", "target", "yyyy-MM-dd")
  v.after("base", "2020-01-02".parse("yyyy-MM-dd"), "yyyy-MM-dd")
  assert v.hasErrors == false
```

## afterOrEqual
フィールドが指定した日付以降であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
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
フィールドが全部アルファベット文字であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("small") == "abcdefghijklmnopqrstuvwxyz"
  assert params.getStr("large") == "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  v.alpha("small")
  v.alpha("large")
  assert v.hasErrors == false
```

## alphaDash
フィールドが全部アルファベット文字と数字、ダッシュ(-)、下線(_)であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abcABC012-_"
  v.alphaDash("base")
  assert v.hasErrors == false
```

## alphaNum
フィールドが全部アルファベット文字と数字であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abcABC012"
  v.alphaNum("base")
  assert v.hasErrors == false
```

## array
フィールドが配列タイプであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a, b, c"
  v.array("base")
  assert v.hasErrors == false
```

## before
フィールドが指定された日付より前であることをバリデートします。  
`after`ルールと同様に、`Datetime`型の代わりにバリデーション対象のフィールド名を指定できます。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "2020-01-02"
  assert params.getStr("target") == "2020-01-01"
  v.before("base", "target", "yyyy-MM-dd")
  v.before("base", "2020-01-01".parse("yyyy-MM-dd")", "yyyy-MM-dd")
  assert v.hasErrors == false
```

## beforeOrEqual
フィールドが指定した日付以前であることをバリデートします。  
`after`ルールと同様に、`Datetime`型の代わりにバリデーション対象のフィールド名を指定できます。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
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
フィールドが指定された**最小値**と**最大値**の間の値であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getInt("int") == 2
  assert params.getFloat("float") == 2.0
  v.betweenNum("int", 1, 3)
  v.betweenNum("float", 1.9, 2.1)
  assert v.hasErrors == false
```

## betweenStr
フィールドが指定された**最小値**と**最大値**の間の文字数であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("str") == "ab"
  v.betweenStr("str", 1, 3)
  assert v.hasErrors == false
```

## betweenArr
フィールドが指定された**最小値**と**最大値**の間の長さであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("arr") == "a, b"
  v.betweenStr("arr", 1, 3)
  assert v.hasErrors == false
```

## betweenFile
フィールドが指定された**最小値**と**最大値**の間のサイズであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("file").len == 2048
  v.betweenFile("file", 1, 3)
  assert v.hasErrors == false
```

## boolean
フィールドが論理値として有効であることをバリデートします。  
受け入れられる入力は、`y, yes, true, 1, on, n, no, false, 0, off`です。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("bool") == "true"
  v.boolean("bool")
  assert v.hasErrors == false
```

## confirmed
フィールドがそのフィールド名＋_confirmationフィールドと同じ値であることをバリデートします。たとえば、バリデーションするフィールドがpasswordであれば、同じ値のpassword_confirmationフィールドが入力に存在していなければなりません。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("password") == "aaa"
  assert params.getStr("password_confirmation") == "aaa"
  assert params.getStr("password_check") == "aaa"
  v.confirmed("password")
  v.confirmed("password", saffix="_check")
  assert v.hasErrors == false
```

## date
パリデーションされる値は有効で相対日付ではないことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "2020-01-01"
  v.date("base", "yyyy-MM-dd")
  assert v.hasErrors == false
```

## dateEquals
バリデーションされる値が、指定した`Datetime`と同じことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("date") == "2020-01-01"
  assert params.getStr("timestamp") == "1577880000"
  let target = "2020-01-01".format("yyyy-MM-dd")
  v.dateEquals("base", "yyyy-MM-dd", target)
  v.dateEquals("timestamp", target)
  assert v.hasErrors == false
```

## different
フィールドが指定された**フィールド**と異なった値を指定されていることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a"
  assert params.getStr("target") == "b"
  v.different("base", "target")
  assert v.hasErrors == false
```

## digits
フィールドが**数値**で、**値**の桁数であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "10"
  v.digits("base", 2)
  assert v.hasErrors == false
```

## digitsBetween
フィールドが**整数**で、桁数が**最小値**から**最大値**の間であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "10"
  v.digitsBetween("base", 1, 3)
  assert v.hasErrors == false
```

## distinctArr
対象が配列の時、フィールドに重複した値がないことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a, b, c"
  v.distinctArr("base")
  assert v.hasErrors == false
```

## domain
フィールドが有効な`A`または`AAAA`レコードであることをバリデーションします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("v4") == "domain.com"
  assert params.getStr("v6") == "[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]"
  v.domain("v4")
  v.domain("v6")
  assert v.hasErrors == false
```

## email
フィールドがメールアドレスとして正しいことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "email@domain.com"
  v.email("base")
  assert v.hasErrors == false
```

## endsWith
フィールドの値が、指定された値で終わることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abcdefg"
  v.email("base", ["ef", "fg"])
  assert v.hasErrors == false
```

## file
フィールドがアップロードに成功したファイルであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params["base"].ext == "jpg"
  v.file("base")
  assert v.hasErrors == false
```

## filled
フィールドが存在する場合、空でないことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a"
  v.filled("base")
  assert v.hasErrors == false
```

## gtNum
フィールドが指定したフィールドより大きい値であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getInt("base") == 2
  assert params.getInt("target") == 1
  v.gtFile("base", "target")
  assert v.hasErrors == false
```

## gtFile
フィールドが指定したフィールドより大きいサイズであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base").len == 2048
  assert params["base"].ext == "jpg"
  assert params.getStr("target").len == 1024
  assert params["target"].ext == "jpg"
  v.gtFile("base", "target")
  assert v.hasErrors == false
```

## gtStr
フィールドが指定したフィールドより長いことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "ab"
  assert params.getStr("target") == "a"
  v.gtStr("base", "target")
  assert v.hasErrors == false
```

## gtArr
フィールドが指定したフィールドより長いことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a, b"
  assert params.getStr("target") == "a"
  v.gtArr("base", "target")
  assert v.hasErrors == false
```

## gteNum
フィールドが指定したフィールド以上の値であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getInt("base") == 2
  assert params.getInt("same") == 2
  assert params.getInt("target") == 1
  v.gtFile("base", "target")
  v.gtFile("base", "same")
  assert v.hasErrors == false
```

## gteFile
フィールドが指定したフィールド以上のサイズであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base").len == 2048
  assert params.getStr("same").len == 2048
  assert params.getStr("target").len == 1024
  v.gteFile("base", "target")
  v.gteFile("base", "same")
  assert v.hasErrors == false
```

## gteStr
フィールドが指定したフィールド以上の文字数であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "ab"
  assert params.getStr("same") == "bc"
  assert params.getStr("target") == "a"
  v.gteStr("base", "target")
  v.gteStr("base", "same")
  assert v.hasErrors == false
```

## gteArr
フィールドが指定したフィールド以上の長さであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a, b"
  assert params.getStr("same") == "b, c"
  assert params.getStr("target") == "a"
  v.gteArr("base", "target")
  v.gteArr("base", "same")
  assert v.hasErrors == false
```

## image
フィールドで指定されたファイルが画像(jpg、png、bmp、gif、svg、webp)であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params["base"].ext == "jpg"
  v.image("base")
  assert v.hasErrors == false
```

## in
フィールドが指定したリストの中の値に含まれていることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params["base"].ext == "a"
  v.in("base", ["a", "b"])
  assert v.hasErrors == false
```

## inArray
フィールドが、**他のフィールド**の値のどれかであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a"
  assert params.getStr("target") == "a, b, c"
  v.inArray("base", "target")
  assert v.hasErrors == false
```

## integer
フィールドが整数値であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getInt("base") == 1
  v.integer("base")
  assert v.hasErrors == false
```

## json
フィールドが有効なJSON文字列であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == """{"key": "value"}"""
  v.json("base")
  assert v.hasErrors == false
```

## ltNum
フィールドが指定したフィールドより小さい値であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getInt("base") == 1
  assert params.getInt("target") == 2
  v.ltNum("base", "target")
  assert v.hasErrors == false
```

## ltFile
フィールドが指定したフィールドより小さいサイズことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base").len == 1024
  assert params.getStr("target").len == 2048
  v.ltFile("base", "target")
  assert v.hasErrors == false
```

## ltStr
フィールドが指定したフィールドより短いことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a"
  assert params.getStr("target") == "ab"
  v.ltStr("base", "target")
  assert v.hasErrors == false
```

## ltArr
フィールドが指定したフィールドより短いことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a"
  assert params.getStr("target") == "a, b"
  v.ltStr("base", "target")
  assert v.hasErrors == false
```

## lteNum
フィールドが指定したフィールド以下の値であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getInt("base") == 1
  assert params.getInt("same") == 1
  assert params.getInt("target") == 2
  v.ltNum("base", "target")
  v.ltNum("base", "same")
  assert v.hasErrors == false
```

## lteFile
フィールドが指定したフィールド以下のサイズであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base").len == 1024
  assert params.getStr("same").len == 1024
  assert params.getStr("target").len == 2048
  v.lteFile("base", "target")
  v.lteFile("base", "same")
  assert v.hasErrors == false
```

## lteStr
フィールドが指定したフィールド以下の文字数であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a"
  assert params.getStr("same") == "b"
  assert params.getStr("target") == "ab"
  v.lteStr("base", "target")
  v.lteStr("base", "same")
  assert v.hasErrors == false
```

## ltArr
フィールドが指定したフィールド以下の長さであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base").len == "a"
  assert params.getStr("same").len == "a"
  assert params.getStr("target").len == "a, b"
  v.ltStr("base", "target")
  v.ltStr("base", "same")
  assert v.hasErrors == false
```

## maxNum
フィールドが最大値として指定された値以下であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getInt("base") == 2
  assert params.getInt("small") == 1
  v.maxNum("base", 2)
  v.maxNum("small", 2)
  assert v.hasErrors == false
```

## maxFile
フィールドが最大値として指定された値以下のサイズであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base").len == 2048
  assert params.getStr("small").len == 1024
  v.maxFile("base", 2)
  v.maxFile("small", 2)
  assert v.hasErrors == false
```

## maxStr
フィールドが最大値として指定された値以下の文字数であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "ab"
  assert params.getStr("small") == "a"
  v.maxStr("base", 2)
  v.maxStr("small", 2)
  assert v.hasErrors == false
```

## maxArr
フィールドが最大値として指定された値以下の長さであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a, b"
  assert params.getStr("small") == "a"
  v.maxArr("base", 2)
  v.maxArr("small", 2)
  assert v.hasErrors == false
```

## mimes
フィールドで指定されたファイルが拡張子のリストの中のMIMEタイプのどれかと一致することをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params["base"].ext == "jpg"
  v.mimes("base", ["jpg", "gif"])
  assert v.hasErrors == false
```

## minNum
フィールドが最小値として指定された値以上であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getInt("base") == 2
  v.minNum("base", 1)
  v.minNum("base", 2)
  assert v.hasErrors == false
```

## minFile
フィールドが最小値として指定された値以上のサイズであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base").len == 2048
  v.minFile("base", 1)
  v.minFile("base", 2)
  assert v.hasErrors == false
```

## minStr
フィールドが最小値として指定された値以上の文字数であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "ab"
  v.minStr("base", 1)
  v.minStr("base", 2)
  assert v.hasErrors == false
```

## minArr
フィールドが最小値として指定された値以上の長さであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a, b"
  v.minArr("base", 1)
  v.minArr("base", 2)
  assert v.hasErrors == false
```

## notIn
フィールドが指定された値のリスト中に含まれていないことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a"
  v.notIn("base", ["b", "c"])
  assert v.hasErrors == false
```

## notRegex
フィールドが指定した正規表現と一致しないことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abc"
  v.notRegex("base", re"\d")
  assert v.hasErrors == false
```

## numeric
フィールドは数値であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getInt("base") == 1
  assert params.getFloat("float") == -1.23
  v.numeric("base")
  v.numeric("float")
  assert v.hasErrors == false
```

## present
フィールドが存在していることをバリデートしますが、存在していれば空を許します。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == ""
  v.present("base")
  assert v.hasErrors == false
```

## regex
フィールドが指定された正規表現にマッチすることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abc"
  v.regex("base", re"\w")
  assert v.hasErrors == false
```

## required
フィールドが入力データに存在しており、かつ空でないことをバリデートします。フィールドは以下の条件の場合、「空」であると判断されます。
- 値が`null`である。
- 値が空文字列である。
- 値が空の配列か、空の`Countable`オブジェクトである。
- 値がパスのないアップロード済みファイルである。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abc"
  v.required("base")
  assert v.hasErrors == false
```

## requiredIf
他のフィールドが値のどれかと一致している場合、このフィールドが存在し、かつ空でないことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("empty") == ""
  assert params.getStr("other") == "123"
  v.requiredIf("base", "other", ["123"])
  v.requiredIf("empty", "other", ["xyz"])
  assert v.hasErrors == false
```

## requiredUnless
他のフィールドが値のどれとも一致していない場合、このフィールドが存在し、かつ空でないことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("empty") == ""
  assert params.getStr("other") == "123"
  v.requiredUnless("base", "other", ["123"])
  v.requiredUnless("empty", "other", ["123"])
  assert v.hasErrors == false
```

## requiredWith
指定した他のフィールドが一つでも存在している場合、このフィールドが存在し、かつ空でないことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("other") == "123"
  v.requiredWith("base", ["a"])
  v.requiredWith("base", ["other"])
  assert v.hasErrors == false
```

## requiredWithAll
指定した他のフィールドがすべて存在している場合、このフィールドが存在し、かつ空でないことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("empty") == ""
  assert params.getStr("other1") == "123"
  assert params.getStr("other2") == "123"
  v.requiredWithAll("valid", ["other1", "other2"])
  v.requiredWithAll("empty", ["notExists"])
  assert v.hasErrors == false
```

## requiredWithout
指定した他のフィールドのどれか一つでも存在していない場合、このフィールドが存在し、かつ空でないことをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("empty") == ""
  assert params.getStr("other") == "123"
  v.requiredWithoutAll("base", ["aaa", "bbb"])
  v.requiredWithoutAll("empty", ["other"])
  assert v.hasErrors == false
```

## same
フィールドが、指定されたフィールドと同じ値であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abc"
  assert params.getStr("target") == "abc"
  v.same("base", "target")
  assert v.hasErrors == false
```

## sizeNum
フィールドは指定された値と同じサイズであることをバリデートします。数値項目の場合、値は整数値です。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getInt("base") == 2
  v.sizeNum("base", 2)
  assert v.hasErrors == false
```

## sizeFile
フィールドは指定された値と同じサイズであることをバリデートします。ファイルの場合、値はキロバイトのサイズです。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base").len == 2048
  v.sizeFile("base", 2)
  assert v.hasErrors == false
```

## sizeStr
フィールドは指定された値と同じサイズであることをバリデートします。文字列の場合、値は文字長です。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "ab"
  v.sizeStr("base", 2)
  assert v.hasErrors == false
```

## sizeArr
フィールドは指定された値と同じサイズであることをバリデートします。配列の場合、値は配列の個数(length)です。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a, b"
  v.sizeArr("base", 2)
  assert v.hasErrors == false
```

## startsWith
フィールドが、指定した値のどれかで始まることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "abcde"
  v.startsWith("base", ["abc", "bcd"])
  assert v.hasErrors == false
```

## timestamp
フィールドが、有効なタイムスタンプであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "1577804400"
  v.timestamp("base")
  assert v.hasErrors == false
```

## url
フィールドが有効なURLであることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "https://google.com:8000/xxx/yyy/zzz?key=value"
  v.url("base")
  assert v.hasErrors == false
```

## uuid
フィールドが有効な、RFC 4122（バージョン1、3、4、5）universally unique identifier (UUID)であることをバリデートします。
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  assert params.getStr("base") == "a0a2a2d2-0b87-4a18-83f2-2529882be2de"
  v.url("base")
  assert v.hasErrors == false
```
