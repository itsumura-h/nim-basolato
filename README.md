Basolato Framework
===
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

Following libralies are not installed by automatically, but I have highly recommandation to you to install and use them for creating modern web app.
- [Karax](https://github.com/pragmagic/karax), Single page applications for Nim.


# index
- [Introduction and Installation](#Introduction)
- [Routing](#Routing)
- [Controller](#Controller)
- [Model](#Model)

# Introduction
## Install
```
nimble install https://github.com/itsumura-h/nim-basolato
```

## Set up
First of all, add nim binary path
```
export PATH=$PATH:~/.nimble/bin
```
After install basolato, "ducere" command is going to be available.

## Create project
```
cd /your/project/dir
ducere new
```

project directory will be created!
```
|--app
|  |--controllers
|  |--models
|--config
|  |--CustomHeaders.nim
|  |--database.ini
|--main.nim
|--migrations
|  |--0001migration.nim
|--public
|--resources
```

You can specify project direcotry name
```
cd /your/project/dir
ducere new project_name
>> create project to /your/project/dir/project_name
```

# Routing
[to index](#index)

Routing is written in `main.nim`. it is the entrypoint file of Basolato.  
Routing of Basolato is exactory the same as `Jester`, although you can call controller method by `route()`
```
import basolato/routing
import app/controllers/SomeController

routes:
  get "/":
    route(SomeController.index())
  get "/@id":
    route(SomeController.index(@"id"))
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
```
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
```
import basolato/routing
import basolato/middleware

from config/middlewares import someMiddleware
import app/controllers/SomeController

routes:
  get "/":
    middlware([loginCheck(request), someMiddleware()])
    route(SomeController.index())
  get "/@id":
    middlware([loginCheck(request), someMiddleware()])
    route(SomeController.index(@"id"))
```


## Coustom Headers
You can set custom headers by setting 2nd arg or `route()`  
Procs which define custom headers have to return `varges[(key, value: string)]`
```
import basolato/routing
from config/CustomHeaders import corsHeader
import app/controllers/SomeController

routes:
  get "/":
    route(SomeController.index(), corsHeader(request))
  get "/@id":
    route(SomeController.index(@"id"), corsHeader(request))
```


# Controller
[to index](#index)

# Model
[to index](#index)
