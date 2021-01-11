Routing
===
[戻る](../../README.md)

Routing is written in `main.nim`. it is the entrypoint file of Basolato.
```nim
import basolato
import app/controllers/some_controller

var routes = newRoutes()

routes.get("/", some_controller.index)
routes.post("/", some_controller.create)
```

Table of Contents

<!--ts-->
   * [Routing](#routing)
      * [HTTP_Verbs](#http_verbs)
      * [Routing group](#routing-group)
      * [URL Params](#url-params)

<!-- Added by: root, at: Sun Dec 27 18:19:16 UTC 2020 -->

<!--te-->


## HTTP_Verbs
Following HTTP Verbs are valid.

|verb|explanation|
|---|---|
|get|Gets list of resources.|
|post|Creates new resource.|
|put|Updates single resource.|
|patch|Updates single resource.|
|delete|Deletes single resource.|
|head|Gets the same response but without response body.|
|options|Gets list of response headers before post/put/patch/delete/ access by client API software such as [Axios/JavaScript](https://github.com/axios/axios) and [Curl/sh](https://curl.haxx.se/).|
|trace|Performs a message loop-back test along the path to the target resource, providing a useful debugging mechanism.|
|connect|Starts two-way communications with the requested resource. It can be used to open a tunnel.|
|error|Catch exception or HttpCode|
|before|Run before get/post/put/patch/delete access.|
|after|Run after get/post/put/patch/delete access.|

## Routing group
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
`/dashboard/url1` and `/dashboard/url2` are available.

## URL Params
Basolato can specify url params with type of `int` and `str`

```nim
import basolato
import app/controllers/some_controller

var routes = newRoutes()

routes.get("/{id:int}", some_controller.show)
routes.get("/{name:str}", some_controller.showByName)
```

|request URL|Called controller|
|---|---|
|`/1`|some_controller.show|
|`/100`|some_controller.show|
|`/john`|some_controller.showByName|
|`/1/john`|not match and responde 404|
