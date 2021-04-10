Routing
===
[戻る](../../README.md)

ルーティングは`main.nim`に書かれます。これはBasolatoのエントリーポイントでもあります。
```nim
import basolato
import app/controllers/some_controller

var routes = newRoutes()

routes.get("/", some_controller.index)
routes.post("/", some_controller.create)
```

コンテンツ

<!--ts-->
   * [Routing](#routing)
      * [HTTP動詞](#http動詞)
      * [ルーティンググループ](#ルーティンググループ)
      * [URL Params](#url-params)

<!-- Added by: root, at: Sat Apr 10 18:36:19 UTC 2021 -->

<!--te-->


## HTTP動詞
以下のHTTP動詞が使えます。

|verb|explanation|
|---|---|
|get|一覧取得|
|post|新規作成|
|put|一つのデータの更新|
|patch|一つのデータの更新|
|delete|一つのデータの削除|
|head|レスポンスボディ無しで同じレスポンスを取得する|
|options|[Axios/JavaScript](https://github.com/axios/axios)や[Curl/sh](https://curl.haxx.se/)のようなクライアントAPIソフトウェアによるpost/put/patch/delete/アクセス前にレスポンスヘッダのリストを取得する|
|trace|対象リソースへのパスに沿ってメッセージのループバックテストを実行します。|
|connect|対象リソースで識別されるサーバーとの間にトンネルを確立します。|

## ルーティンググループ
```nim
import basolato
import app/controllers/some_controller
import app/controllers/dashboard_controller


var routes = newRoutes()

routes.get("/", some_controller.index)

groups "/dashboard":
  routes.get("/url1", dashboard_controller.url1)
  routes.get("/url2", dashboard_controller.url2)
```
`/dashboard/url1`と`/dashboard/url2`が有効なURLになります。

## URL Params
BasolatoはURLパラメータを`int`と`str`を使って型指定することができます。

```nim
import basolato
import app/controllers/some_controller

var routes = newRoutes()

routes.get("/{id:int}", some_controller.show)
routes.get("/{name:str}", some_controller.showByName)
```

|リクエストURL|呼ばれるコントローラー|
|---|---|
|`/1`|some_controller.show|
|`/100`|some_controller.show|
|`/john`|some_controller.showByName|
|`/1/john`|not match and responde 404|
