Routing
===
[back](../README.md)

Routing is written in `main.nim`. it is the entrypoint file of Basolato.  
Routing of Basolato is exactory the same as `Jester`, although you can call controller method by `route()`
```nim
import basolato/routing
import app/controllers/SomeController

routes:
  get "/":
    route(newSomeController(request).index())
  post "/":
    route(newSomeController(request).create())
  get "/@id":
    route(newSomeController(request).show(@"id"))
```

Table of Contents

<!--ts-->
   * [Routing](#routing)
      * [HTTP_Verbs](#http_verbs)
      * [Routing group](#routing-group)
      * [Getting response in sepecific URL groups](#getting-response-in-sepecific-url-groups)

<!-- Added by: root, at: Fri Jul 31 13:19:28 UTC 2020 -->

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
This functions is definded in `jester`
```nim
router dashboard:
  get "/url1":
    route(newDashboardController(request).url1())
  get "/url2":
    route(newDashboardController(request).url2())

routes:
  extend dashboard, "/dashboard"
```
`/dashboard/url1` and `/dashboard/url2` are available.


## Getting response in sepecific URL groups
`response(result)` return a instance of `Response`. This has some fields.
```nim
after re"/api.*":
  echo response(result).body
  echo response(result).headers
  echo response(result).status

extend api, "/api"
```
