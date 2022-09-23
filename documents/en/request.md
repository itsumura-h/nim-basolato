Request
===
[back](../../README.md)

Table of Contents

<!--ts-->
* [Request](#request)
   * [Getting params](#getting-params)
      * [API](#api)
   * [Save file](#save-file)
      * [API](#api-1)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Fri Sep 23 13:12:57 UTC 2022 -->

<!--te-->

## Getting params
All of `request params`, `url params`, `query params` is stored in `params:Params`.

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

## Save file

```html
<input type="file" name="img">
```

```nim
proc store*(request:Request, params:Params):Future[Response] {.async.} =
  if params.hasKey("img"):
    # save as original file name in public/sample
    params.save("img", "./public/sample")

    # save and rename in public/sample/image.jpg
    params.save("img", "./public/sample", "image")
```

### API
```nim
proc save*(params:Params, key, dir:string) =

proc save*(params:Params, key, dir, newFileName:string) =
```
