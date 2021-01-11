コントローラー
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [Controller](#controller)
      * [Creating a Controller](#creating-a-controller)
      * [How to get params](#how-to-get-params)
         * [Request params](#request-params)
         * [Url params](#url-params)
         * [Query params](#query-params)
      * [Response](#response)
         * [Returning string](#returning-string)
         * [Returning HTML file](#returning-html-file)
         * [Returning template](#returning-template)
         * [Returning JSON](#returning-json)
         * [Response with status](#response-with-status)
         * [Response with header](#response-with-header)
      * [Redirect](#redirect)

<!-- Added by: root, at: Sun Dec 27 18:22:28 UTC 2020 -->

<!--te-->

## イントロダクション


## コントローラー作成
コントローラーを作るには、`ducere`コマンドを使います。  
[ducere make controller](./ducere.md#コントローラー)

リソースコントローラーは、基本的なCRUDを実装するためのリソース指向のメソッドを持っています。

```nim
from json
# framework
import basolato/controller


proc index*(request:Request, params:Params):Future[Response] {.async.} =
  return render("index")

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("show")

proc create*(request:Request, params:Params):Future[Response] {.async.} =
  return render("create")

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  return render("store")

proc edit*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("edit")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("update")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("destroy")
```

各メソッドはそれぞれに呼び出されるべきユースケースが決まっています。

|HTTPメソッド|URLパス|コントローラーメソッド|ユースケース|
|---|---|---|---|
|GET|/posts|index|全件表示|
|GET|/posts/create|create|新規登録画面表示|
|POST|/posts|store|新規登録|
|GET|/posts/{id}|show|1件表示|
|GET|/posts/{id}/edit|edit|1件編集画面表示|
|POST|/posts/{id}|update|1件編集|
|DELETE|/posts/{id}|destroy|1件削除|

## パラメータの取得
### リクエストパラメータ
view
```html
<input type="text" name="email">
```

controller
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.requestParams.get("email")
```

### Urlパラメータ
routing
```nim
var routes = newRoutes()
routes.get("/{id:int}", some_controller.show)
```

controller
```nim
proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
```

### クエリパラメータ
URL
```
/updates?queries=500
```

controller
```nim
proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let queries = params.queryParams["queries"].parseInt
```

## レスポンス
### 文字列を返す
`render`関数の引数に文字列を入れると、コントローラーは文字列を返します。
```nim
return render("index")
```

### HTMLファイルを返す
`html`関数の引数にHTMLファイルへのパスを指定すると、HTMLファイルの中身を返します。  
ファイルパスには`resources`ディレクトリからの相対パスを指定してください。
```nim
return render(html("sample/index.html"))
# もしくは
return render(await asyncHtml("sample/index.html"))

>> /resources/sample/index.html が表示される
```

### テンプレートを返す
テンプレートの関数を`render`関数の引数に入れて呼ぶことで、テンプレートエンジンによって描画されたHTMLを返します。

resources/sample/index_view.nim
```nim
import basolato/view

proc indexView(name:string):string = tmpli html"""
<h1>index</h1>
<p>$name</p>
"""
```
controller
```nim
return render(indexView("John"))
```

### JSONを返す
`render`関数の引数に`JsonNode`型を入れると、JSONが返ります。
```nim
return render(%*{"key": "value"})
```

### レスポンスステータスを設定する
`render`関数の第一引数に`HttpCode`を、第二引数にレスポンスボディを入れます。
```nim
return render(HTTP500, "It is a response body")
```

[有効なHTTPステータスコード一覧](https://nim-lang.org/docs/httpcore.html#10)
[HTTPステータスの定義とその意味](https://ja.wikipedia.org/wiki/HTTPステータスコード)


### レスポンスヘッダーを設定する
`render`関数の最後にヘッダーを入れてください
```nim
var header = newHeaders()
header.set("key1", "value1")
header.set("key2", ["value1", "value2"])
return render("setHeader", header)
```

`render`関数は以下の様々なレスポンスにもヘッダーを設定することができます
```nim
return render(%*{"key": "value"}, header)
return render(Http400, "setHeader", header)
return render(Http400, %*{"key": "value"}, header)
```

## リダイレクト
`redirect`関数を使います
```nim
return redirect("https://nim-lang.org")

return errorRedirect("/login")
```
