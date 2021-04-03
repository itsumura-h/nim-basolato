
<p align="center">
  <img src="./documents/images/basolato.svg" style="width:160px">
</p>
<div align="center">
  <h1>Basolato Framework</h1>
  <img src="https://github.com/itsumura-h/nim-basolato/workflows/Build%20and%20test%20Nim/badge.svg">
</div>

---

An asynchronous full-stack web framework for Nim, based on [asynchttpserver](https://nim-lang.org/docs/asynchttpserver.html).

:warning: This project is under heavy development. It's not yet production-ready. :warning:

## Table of Contents

<!--ts-->
   * [Basolato Framework](#basolato-framework)
      * [Table of Contents](#table-of-contents)
      * [Introduction](#introduction)
         * [Set up your environment](#set-up-your-environment)
         * [Dependencies](#dependencies)
         * [Installation](#installation)
         * [Creating projects](#creating-projects)
      * [Documentation](#documentation)
      * [Benchmark](#benchmark)
      * [Roadmap](#roadmap)
      * [Development](#development)
         * [Generate TOC of documents](#generate-toc-of-documents)

<!-- Added by: root, at: Sat Apr  3 12:46:10 UTC 2021 -->

<!--te-->


## Introduction
Basolato extends [asynchttpserver](https://nim-lang.org/docs/asynchttpserver.html), an implements a high performance asynchronous HTTP server in Nim std library, while also adding features for full-stack development. It was also heavily inspired by other frameworks:

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
- [nim-templates](https://github.com/onionhammer/nim-templates), a simple string templating library.
- [allographer](https://github.com/itsumura-h/nim-allographer), a library for building queries.
- [flatdb](https://github.com/enthus1ast/flatdb), a small Flatfile database, used for sessions.
- [bcrypt](https://github.com/runvnc/bcryptnim), used for hashing passwords.
- [nimAES](https://github.com/jangko/nimAES), for AES support.
- [faker](https://github.com/jiro4989/faker), for generating fake data.
- [sass](https://github.com/dom96/sass), provides a Sass/SCSS to CSS compiler for `Nim` through bindings to `libsass`.


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
├── app
│   ├── core
│   │   ├── models
│   │   └── usecases
│   ├── di_container.nim
│   ├── http
│   │   ├── controllers
│   │   │   └── welcome_controller.nim
│   │   ├── middlewares
│   │   │   ├── auth_middleware.nim
│   │   │   └── cors_middleware.nim
│   │   └── views
│   │       ├── layouts
│   │       │   ├── application_view.nim
│   │       │   └── head_view.nim
│   │       └── pages
│   │           └── welcome_view.nim
│   └── repositories
│       └── query_services
│           ├── query_service.nim
│           └── query_service_interface.nim
├── config.nims
├── config.nims.dev
├── config.nims.prd
├── config.nims.stg
├── main.nim
├── migrations
│   └── migrate.nim
├── public
│   ├── basolato.svg
│   ├── css
│   ├── favicon.ico
│   └── js
├── session.db
├── test1.nimble
└── tests
    └── test_sample.nim
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

- [ducere CLI tool](./documents/en/ducere.md)
- [Routing](./documents/en/routing.md)
- [Controller](./documents/en/controller.md)
- [Request](./documents/en/request.md)
- [Middleware](./documents/en/middleware.md)
- [Headers](./documents/en/headers.md)
- [Migration](./documents/en/migration.md)
- [View](./documents/en/view.md)
- [Error](./documents/en/error.md)
- [Validation](./documents/en/validation.md)
- [Security (CsrfToken, Cookie, Session, Auth)](./documents/en/security.md)
- [Helper](./documents/en/helper.md)
- [Logging](./documents/en/logging.md)

## Benchmark
- https://github.com/the-benchmarker/web-frameworks
- https://www.techempower.com/benchmarks/#section=test&shareid=d57ac3fe-2855-40ec-ac7a-424d34ce7a92&hw=ph&test=json&a=2

## Roadmap

|Version|Content|
|---|---|
|v1.0|Support Clean architecture and Tactical DDD|
|v2.0|Support GraphQL|

## Development

### Generate TOC of documents

Run.

```bash
nimble setupTool # Build docker image
nimble toc # Generate TOC
```
