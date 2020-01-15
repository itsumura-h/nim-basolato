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

# index
- [decere command](./documents/ducere.md)
- [Routing](./documents/routing.md)
- [Controller](#Controller)
- [Middleware](./documents/middleware.md)
- [Model](#Model)

# Controller
[to index](#index)

## Creating a Controller
Use `ducere` command  
[`ducere make controller`](./documents/ducere.md#controller)

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


# Migration
[to index](#index)

## Creating a Migration File
Use `ducere` command  
[`ducere make migration`](./documents/ducere.md#migration)

To create table schema, read `allographer` documents.  
[allographer](https://github.com/itsumura-h/nim-allographer/blob/master/documents/schema_builder.md)


# Model
[to index](#index)
