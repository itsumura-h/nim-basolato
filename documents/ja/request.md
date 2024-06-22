リクエスト
===
[戻る](../../README.md)

目次
<!--ts-->


<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 10:32:02 UTC 2024 -->

<!--te-->

## パラメータの取得
リクエストパラメータ、URLパラメータ、クエリパラメータのすべてが `params:Params` に格納されます。

```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let email = params.getStr("email")
```

### API
```nim
proc getStr*(params:Params, key:string, default=""):string

proc getInt*(params:Params, key:string, default=0):int

proc getFloat*(params:Params, key:string, default=0.0):float

proc getBool*(params:Params, key:string, default=false):bool

proc getJson*(params:Params, key:string, default=newJObject()):JsonNode

proc getAll*(params:Params):JsonNode
```

## ファイル保存

```html
<input type="file" name="img">
```

```nim
proc store*(request:Request, params:Params):Future[Response] {.async.} =
  if params.hasKey("img"):
    # public/sampleにオリジナルのファイル名のまま保存する
    params.save("img", "./public/sample")

    # public/sample/image.jpgにリネームして保存する
    params.save("img", "./public/sample", "image")
```

### API
```nim
proc save*(params:Params, key, dir:string) =

proc save*(params:Params, key, dir, newFileName:string) =
```
