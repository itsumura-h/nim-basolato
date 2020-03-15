
<p align="center">
  <img src="./documents/basolato.svg" style="width:160px">
</p>
<div align="center">
  <h2>Basolato Framework</h2>
  <img src="https://github.com/itsumura-h/nim-basolato/workflows/Build%20and%20test%20Nim/badge.svg">
</div>

---

A Fullstack Web Framework for Nim based on Jester

:warning: This is in development :grimacing::sweat_drops:

To references

|Language|Framework|
|---|---|
|Ruby|Rails|
|PHP|Laravel|
|Python|Masonite|
|Java/Scala|Play|
|Go|Revel|

## Dependencies
This framework depends on following libralies
- [Jester](https://github.com/dom96/jester), Micro web framework.
- [Karax](https://github.com/pragmagic/karax), Single page applications for Nim, as view.
- [allographer](https://github.com/itsumura-h/nim-allographer), Query builder library.
- [flatdb](https://github.com/enthus1ast/flatdb), a small flatfile, inprocess database for nim-lang, as session DB.
- [bcrypt](https://github.com/runvnc/bcryptnim), useful for hashing passwords.
- [nimAES](https://github.com/jangko/nimAES), Advanced Encryption Standard.

Following libralies are another options to create view.
- [nim-templates](https://github.com/onionhammer/nim-templates), A simple string templating library
- [react.nim](https://github.com/andreaferretti/react.nim), React.js bindings for Nim.
- [react-16.nim](https://github.com/kristianmandrup/react-16.nim), React 16.x bindings for Nim 1.0 with example app (WIP).


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
├── main.nim
├── middleware
│   ├── custom_headers_middleware.nim
│   └── framework_middleware.nim
├── migrations
│   ├── migrate.nim
│   └── migration0001.nim
├── public
└── resources
```

You can specify project direcotry name
```sh
cd /your/project/dir
ducere new project_name
>> create project to /your/project/dir/project_name
```

run server 
```
nim c -r main
 or
./server.sh # requiring "inotify" and "inotifywait", Hot reload is available
```

# Documents
- [decere CLI tool](./documents/ducere.md)
- [Routing](./documents/routing.md)
- [Controller](./documents/controller.md)
- [Middleware](./documents/middleware.md)
- [Headers](./documents/headers.md)
- [Model](./documents/model.md)
- [Migration](./documents/migration.md)
- [View](./documents/view.md)
- [Error](./documents/error.md)
- [Validation](./documents/validation.md)
- [Security(CsrfToken, Cookie, Session, Auth)](./documents/security.md)
- [Helper](./documents/helper.md)

## Dev roadmap

|Version|Content|
|---|---|
|v1.0|Support Three-layer architecture (generally called as MVC)|
|v2.0|Support Clean architecture, Tactical DDD|
|v3.0|Support GraphQL|