コントローラー
===
[戻る](../../README.md)

目次
<!--ts-->
   * [コントローラー](#コントローラー)
      * [イントロダクション](#イントロダクション)
      * [コントローラーの作成](#コントローラーの作成)
      * [パラメータの取得方法](#パラメータの取得方法)
         * [リクエストパラメータ](#リクエストパラメータ)
         * [Urlパラメータ](#urlパラメータ)
         * [クエリパラメータ](#クエリパラメータ)
      * [レスポンス](#レスポンス)
         * [文字列を返す](#文字列を返す)
         * [HTMLファイルを返す](#htmlファイルを返す)
         * [テンプレートを返す](#テンプレートを返す)
         * [JSONを返す](#jsonを返す)
         * [ステータス付きレスポンス](#ステータス付きレスポンス)
         * [ヘッダー付きレスポンス](#ヘッダー付きレスポンス)
      * [リダイレクト](#リダイレクト)

<!-- Added by: root, at: Fri Dec 31 11:51:49 UTC 2021 -->

<!--te-->

## イントロダクション
コントローラーは、ウェブ特有の責任を解決し、ビジネスロジックを呼び出す層です。

## コントローラーの作成
`ducere`コマンドを使います。  
[ducere make controller](./ducere.md#controller)

リソースコントローラは、基本的なCRUD/リソーススタイルのメソッドを持つコントローラです。

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

各メソッドは、以下のリストに従って呼び出す必要があります。

|HTTP method|URL path|controller method|usecase|
|---|---|---|---|
|GET|/posts|index|すべての記事を表示する|
|GET|/posts/create|create|新規投稿ページの表示|
|POST|/posts|store|新規投稿|
|GET|/posts/{id}|show|1つの記事を表示する|
|GET|/posts/{id}/edit|edit|1つの記事編集ページを表示|
|POST|/posts/{id}|update|1つの記事を更新|
|DELETE|/posts/{id}|destroy|1つの記事を削除する|

## パラメータの取得方法
### リクエストパラメータ
view
```html
<input type="text" name="email">
```

controller
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
```

### Urlパラメータ
routing
```nim
var routes = Routes.new()
routes.get("/{id:int}", some_controller.show)
```

controller
```nim
proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
```

### クエリパラメータ
URL
```
/updates?queries=500
```

controller
```nim
proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let queries = params.getInt("queries")
```

## レスポンス
### 文字列を返す
`render`関数で文字列を設定した場合、コントローラは文字列を返します。
```nim
return render("index")
```

### HTMLファイルを返す
`html`関数にhtmlファイルのパスを設定すると、コントローラはHTMLを返します。  
このファイルパスは `app/http/views` ディレクトリからの相対パスでなければなりません。

```nim
return render(html("pages/sample/index.html"))
# or
return render(await asyncHtml("pages/sample/index.html"))

>> display app/http/views/pages/sample/index.html
```

### テンプレートを返す
`render`関数で引数を指定してテンプレートの実装関数を呼び出すと、テンプレートが返されます。

app/http/views/pages/sample/index_view.nim
```nim
import basolato/view

proc indexView(name:string):string = tmpli html"""
<h1>index</h1>
<p>$name</p>
"""
```
main.nim
```nim
return render(indexView("John"))
```

### JSONを返す
`render`関数でJsonNodeを設定すると、コントローラはJSONを返します。

```nim
return render(%*{"key": "value"})
```

### ステータス付きレスポンス
第一引数にステータスを、第二引数にレスポンスボディを入れてください。
```nim
return render(Http500, "This is a response body")
```

[使用可能なレスポンスステータス一覧。](https://nim-lang.org/docs/httpcore.html#10)  
[レスポンスステータスの説明。](https://ja.wikipedia.org/wiki/HTTP%E3%82%B9%E3%83%86%E3%83%BC%E3%82%BF%E3%82%B9%E3%82%B3%E3%83%BC%E3%83%89)

### ヘッダー付きレスポンス
`render`関数の最後の引数にヘッダーを入れてください。
```nim
var header = newHttpHeaders()
header.add("key1", "value1")
header.add("key2", ["value1", "value2"])
return render("setHeader", header)
```

次のようにJSONレスポンスやステータス付きの場合もheaderを置くことが出来ます。
```nim
return render(%*{"key": "value"}, header)
return render(Http400, "setHeader", header)
return render(Http400, %*{"key": "value"}, header)
```

## リダイレクト
`redirect`関数を使います.

```nim
return redirect("https://nim-lang.org")
return redirect("https://nim-lang.org", header)

return errorRedirect("/login")
return errorRedirect("/login", header)
```
