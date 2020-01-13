Basolato Framework
===

![Build Status](https://github.com/itsumura-h/nim-basolato/workflows/Build%20and%20test%20Nim/badge.svg)

A Fullstack Web Framework for Nim based on Jester


To references

|Language|Framework|
|---|---|
|Ruby|Rails|
|PHP|Laravel|
|Python|Masonite|
|Java/Scala|Play|
|Go|Revel|

This framework depends on following libralies
- [Jester](https://github.com/dom96/jester), Micro web framework
- [nim-templates](https://github.com/onionhammer/nim-templates), A simple string templating library
- [allographer](https://github.com/itsumura-h/nim-allographer), Query builder library
- [flatdb](https://github.com/enthus1ast/flatdb), a small flatfile, inprocess database for nim-lang. as session DB

Following libralies are not installed by automatically, but I have highly recommandation to you to install and use them for creating modern web app.
- [Karax](https://github.com/pragmagic/karax), Single page applications for Nim.


# index
- [Introduction and Installation](#Introduction)
- [Routing](#Routing)
- [Controller](#Controller)
- [Model](#Model)

# Introduction
## Install
```sh
nimble install https://github.com/itsumura-h/nim-basolato
```

## Set up
First of all, add nim binary path
```sh
export PATH=$PATH:~/.nimble/bin
```
After install basolato, "ducere" command is going to be available.

## Create project
```sh
cd /your/project/dir
ducere new
```

project directory will be created!
```
├── app
│   ├── controllers
│   └── models
├── config.nims
├── logs
│   ├── error.log
│   └── log.log
├── main
├── main.nim
├── middleware
│   └── custom_headers.nim
├── migrations
│   ├── migrate.nim
│   └── migration20200113054007Init.nim
├── public
└── resources
```

You can specify project direcotry name
```sh
cd /your/project/dir
ducere new project_name
>> create project to /your/project/dir/project_name
```

# Routing
[to index](#index)

Routing is written in `main.nim`. it is the entrypoint file of Basolato.  
Routing of Basolato is exactory the same as `Jester`, although you can call controller method by `route()`
```nim
import basolato/routing
import app/controllers/SomeController

routes:
  get "/":
    route(SomeController.index())
  post "/":
    route(SomeController.create(request))
  get "/@id":
    route(SomeController.show(@"id"))
```

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
|error||
|before|Run before get/post/put/patch/delete access.|
|after|Run after get/post/put/patch/delete access.|

## Routing group
This functions is definded in `jester`
```nim
router dashboard:
  get "/url1":
    route(DashboardController.url1())
  get "/url2":
    route(DashboardController.url2())

routes:
  extend dashboard, "/dashboard"
```
`/dashboard/url1` and `/dashboard/url2` are available.


## Middlware
You can run middlware methods before calling controller.  
In following example, `loginCheck(request)` and `someMiddleware()` definded in `config/middlewares` are called
```nim
import basolato/routing
import basolato/middleware

from config/middlewares import loginCheck, someMiddleware
import app/controllers/SomeController

routes:
  get "/":
    middlware([loginCheck(request), someMiddleware()])
    route(SomeController.index())
  post "/":
    middlware([loginCheck(request), someMiddleware()])
    route(SomeController.create(request))
  get "/@id":
    middlware([loginCheck(request), someMiddleware()])
    route(SomeController.show(@"id"))
```


## Coustom Headers
You can set custom headers by setting 2nd arg or `route()`  
Procs which define custom headers have to return `@[(key, value: string)]` or `[(key, value: string)]`
```nim
import basolato/routing

from config/custom_headers import corsHeader
import app/controllers/SomeController

routes:
  get "/":
    route(SomeController.index(), corsHeader(request))
  post "/":
    route(SomeController.create(request), corsHeader(request))
  get "/@id":
    route(SomeController.show(@"id"), corsHeader(request))
```


# Controller
[to index](#index)

## Creating a Controller
`ducere make controller` command can create controller.

```nim
ducere make controller User
>> app/controllers/UserController.nim

ducere make controller sample/User
>> app/controllers/sample/UserController.nim

ducere make controller sample/sample2/User
>> app/controllers/sample/sample2/UserController.nim
```

Resource controllers are controllers that have basic CRUD / resource style methods to them.  
Generated controller is resource controller.

```nim
proc index*(): Response =
  return render("index")

proc show*(idArg: string): Response =
  let id = idArg.parseInt
  return render("show")

proc create*(): Response =
  return render("create")

proc store*(request: Request): Response =
  return render("store")

proc edit*(idArg: string): Response =
  let id = idArg.parseInt
  return render("edit")

proc update*(request: Request): Response =
  return render("update")

proc destroy*(idArg: string): Response =
  let id = idArg.parseInt
  return render("destroy")
```

## Returning string
If you set string in `render` proc, controller returns string.
```nim
proc index*(): Response =
  return render("index")
```

## Returning HTML file
If you set html file path in `html` proc, controller returns HTML.  
This file path should be relative path from `resources` dir

```nim
proc index*(): Response =
  return render(html("sample/index.html"))

>> display /resources/sample/index.html
```

## Returning template
Call template proc with args in `render` will return template

```nim
# resources/sample/index.nim

import tampleates

proc indexHtml(name:string):string = tmpli html"""
<h1>index</h1>
<p>$name</p>
"""
```

```nim
import resources/sample/index

proc index*(): Response =
  return render(indexHtml("John"))
```

## Returning JSON
If you set JsonNode in `render` proc, controller returns JSON.

```nim
proc index*(): Response =
  return render(
    %*{"key": "value"}
  )
```

## Response status
Put response status code arge1 and response body arge2
```nim
proc index*(): Response =
  return render(HTTP500, "It is a response body")
```

[Here](https://nim-lang.org/docs/httpcore.html#10) is the list of response status code available.  
[Here](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) is a experiment of HTTP status code

## Coustom Headers
`headers` proc with method chain with `render` will set custom response header. If same key of header set in `main.nim`, it will be overwitten.
```nim
proc index*(): Response =
  return render("with headers")
    .header("key1", "value1")
    .header("key2", ["a", "b", "c"])
```

# Migration
[to index](#index)

## Creating a Migration File
`ducere make migration` command can create migration file.

```nim
ducere make migration createUser
>> migrations/migration20200219134020createUser.nim
```

To create table schema, read `allographer` documents.  
[allographer](https://github.com/itsumura-h/nim-allographer/blob/master/documents/schema_builder.md)


# Model
[to index](#index)
