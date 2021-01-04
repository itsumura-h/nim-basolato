Request
===
[戻る](../../README.md)

Table of Contents

<!--ts-->
   * [Request](#request)
      * [Getting params](#getting-params)
         * [API](#api)
      * [Save file](#save-file)
         * [API](#api-1)

<!-- Added by: root, at: Sun Dec 27 18:22:49 UTC 2020 -->

<!--te-->

## Getting params
All of `request params`, `url params`, `query params` is stored in `params:Params`.

```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let email = params.getStr("email")
```

If `Content-type` of request is `application/json`, you can get `JsonNode` request params by `params.getJson()`

```nim
proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let jsonParams = params.getJson()
  let id = jsonParams["id"].getInt
  let email = jsonParams["email"].getStr
```

### API
```nim
proc getStr*(params:Params, key:string, default=""):string =

proc getInt*(params:Params, key:string, default=0):int =

proc getFloat*(params:Params, key:string, default=0.0):float =

proc getBool*(params:Params, key:string, default=false):bool =

proc getJson*(params:Params):JsonNode =
```

## Save file

```html
<input type="file" name="img">
```

```nim
proc store*(request:Request, params:Params):Future[Response] {.async.} =
  if params.hasKey("img"):
    # save as original file name in public/sample/img.jpg
    params.save("img", "./public/sample")

    # save and rename in public/sample/image.jpg
    params.save("img", "./public/sample", "image")
```

### API
```nim
proc save*(params:Params, key, dir:string) =

proc save*(params:Params, key, dir, newFileName:string) =
```
