
<p align="center">
  <img src="./documents/basolato.svg" style="width:160px">
</p>
<div align="center">
  <h1>Basolato Framework</h1>
  <img src="https://github.com/itsumura-h/nim-basolato/workflows/Build%20and%20test%20Nim/badge.svg">
</div>

---

A full-stack web framework for Nim, based on [Jester](https://github.com/dom96/jester).

:warning: This project is under heavy development. It's not yet production-ready. :warning:

## Table of Contents

<!--ts-->
   * [Basolato Framework](README.md#basolato-framework)
      * [Table of Contents](README.md#table-of-contents)
      * [Introduction](README.md#introduction)
         * [Set up your environment](README.md#set-up-your-environment)
         * [Dependencies](README.md#dependencies)
         * [Installation](README.md#installation)
         * [Creating projects](README.md#creating-projects)
      * [Documentation](README.md#documentation)
      * [Roadmap](README.md#roadmap)

<!-- Added by: runner, at: Wed Jul 29 09:34:25 UTC 2020 -->

<!--te-->


## Introduction
Basolato extends [Jester](), an awesome Sinatra-like framework for Nim, while also adding features for full-stack development. It was also heavily inspired by other frameworks:

|Language|Framework|
|---|---|
|Ruby|Rails|
|PHP|Laravel|
|Python|Masonite|
|Java/Scala|Play|
|Go|Revel|

### Set up your environment
In order to start using Basolato, you'll first need a working Nim installation. You can find installation instructions for Nim [here](https://nim-lang.org/install.html).
Once installed, make sure Nimble, Nim's package manager, is already in your PATH. If not, add `.nimble/bin` in your favorite shell.

```sh
export PATH=$PATH:~/.nimble/bin
```


### Dependencies

The framework depends on several libraries (installed automatically by Nimble):
- [httpbeast](https://github.com/dom96/httpbeast), a highly performant, multi-threaded HTTP 1.1 server written in Nim.
- [nim-templates](https://github.com/onionhammer/nim-templates), a simple string templating library.
- [allographer](https://github.com/itsumura-h/nim-allographer), a library for building queries.
- [flatdb](https://github.com/enthus1ast/flatdb), a small Flatfile database, used for sessions.
- [bcrypt](https://github.com/runvnc/bcryptnim), used for hashing passwords.
- [nimAES](https://github.com/jangko/nimAES), for AES support.
- [faker](https://github.com/jiro4989/faker), for generating fake data.

The following libraries can be used for making views:
- [Karax](https://github.com/pragmagic/karax), for single-page applications.
- [react.nim](https://github.com/andreaferretti/react.nim), React.js bindings.
- [react-16.nim](https://github.com/kristianmandrup/react-16.nim), React 16.x bindings with an example app (WIP).


### Installation

You can install Basolato easily using Nimble:

```sh
nimble install https://github.com/itsumura-h/nim-basolato
```

After installing Basolato, you should have access to the `ducere` command on your shell.

### Creating projects

Using `ducere` you can easily create a template project structure to start development right away. Ducere will generate a folder automatically using your project name.

```sh
cd /your/project/dir
ducere new {project_name}
```

The overall file structure is as follows:

```
├── .gitignore
├── app
│   ├── controllers
│   │   ├── README.md
│   │   └── welcome_controller.nim
│   ├── domain
│   │   ├── models
│   │   │   ├── README.md
│   │   │   ├── di_container.nim
│   │   │   └── value_objects.nim
│   │   └── usecases
│   │       └── README.md
│   └── middlewares
│       ├── README.md
│       ├── custom_headers_middleware.nim
│       └── framework_middleware.nim
├── config.nims
├── main.nim
├── migrations
│   ├── README.md
│   ├── migrate.nim
│   └── migration0001sample.nim
├── public
│   ├── README.md
│   ├── basolato.svg
│   ├── css
│   ├── favicon.ico
│   └── js
├── resources
│   ├── README.md
│   ├── layouts
│   │   ├── application.nim
│   │   └── head.nim
│   └── pages
│       └── welcome_view.nim
├── session.db
├── {project_name}.nimble
└── tests
```

With your project ready, you can start serving requests using `ducere`:

```sh
ducere serve # includes hot reloading
```

Or by compiling through Nim:
```
nim c -r main
```

## Documentation

- [ducere CLI tool](./documents/ducere.md)
- [Routing](./documents/routing.md)
- [Controller](./documents/controller.md)
- [Middleware](./documents/middleware.md)
- [Headers](./documents/headers.md)
- [Migration](./documents/migration.md)
- [View](./documents/view.md)
- [Error](./documents/error.md)
- [Validation](./documents/validation.md)
- [Security (CsrfToken, Cookie, Session, Auth)](./documents/security.md)
- [Password](./documents/password.md)
- [Helper](./documents/helper.md)

## Benchmark
- https://github.com/the-benchmarker/web-frameworks
- https://github.com/TechEmpower/FrameworkBenchmarks

## Roadmap

|Version|Content|
|---|---|
|v1.0|Support Clean architecture and Tactical DDD|
|v2.0|Support GraphQL|
