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
- [Controller](./documents/controller.md)
- [Middleware](./documents/middleware.md)
- [Headers](./documents/headers.md)
- [View](./documents/view.md)


# Migration
[to index](#index)

## Creating a Migration File
Use `ducere` command  
[`ducere make migration`](./documents/ducere.md#migration)

To create table schema, read `allographer` documents.  
[allographer](https://github.com/itsumura-h/nim-allographer/blob/master/documents/schema_builder.md)


# Model
[to index](#index)
