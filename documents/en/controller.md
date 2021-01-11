Controller
===
[back](../../README.md)

Table of Contents

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

## Creating a Controller
Use `ducere` command  
[ducere make controller](./ducere.md#controller)

Resource controllers are controllers that have basic CRUD / resource style methods to them.

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

Each method should be called according to the following list

|HTTP method|URL path|controller method|usecase|
|---|---|---|---|
|GET|/posts|index|Display all posts|
|GET|/posts/create|create|Display new post page|
|POST|/posts|store|Submit new post|
|GET|/posts/{id}|show|Display one post|
|GET|/posts/{id}/edit|edit|Dpsplay one post edit page|
|POST|/posts/{id}|update|Update one post|
|DELETE|/posts/{id}|destroy|Delete one post|

## How to get params
### Request params
view
```html
<input type="text" name="email">
```

controller
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.requestParams.get("email")
```

### Url params
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

### Query params
URL
```
/updates?queries=500
```

controller
```nim
proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let queries = params.queryParams["queries"].parseInt
```

## Response
### Returning string
If you set string in `render` proc, controller returns string.
```nim
return render("index")
```

### Returning HTML file
If you set html file path in `html` proc, controller returns HTML.  
This file path should be relative path from `resources` dir

```nim
return render(html("sample/index.html"))
# or
return render(await asyncHtml("sample/index.html"))

>> display /resources/sample/index.html
```

### Returning template
Call template proc with args in `render` will return template

resources/sample/index_view.nim
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

### Returning JSON
If you set JsonNode in `render` proc, controller returns JSON.

```nim
return render(%*{"key": "value"})
```

### Response with status
Put response status code arge1 and response body arge2
```nim
return render(HTTP500, "It is a response body")
```

[Here](https://nim-lang.org/docs/httpcore.html#10) is the list of response status code available.  
[Here](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) is a experiment of HTTP status code

### Response with header
Put header at the end of `render`
```nim
var header = newHeaders()
header.set("key1", "value1")
header.set("key2", ["value1", "value2"])
return render("setHeader", header)
```

`render` proc are also followings available.
```nim
return render(%*{"key": "value"}, header)
return render(Http400, "setHeader", header)
return render(Http400, %*{"key": "value"}, header)
```

## Redirect
You can use `redirect` proc.

```nim
return redirect("https://nim-lang.org")

return errorRedirect("/login")
```
