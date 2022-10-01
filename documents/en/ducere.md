Ducere command
===
[back](../../README.md)

Table of Contents

<!--ts-->
* [Ducere command](#ducere-command)
   * [Introduction](#introduction)
   * [Usages](#usages)
      * [new](#new)
      * [serve](#serve)
      * [build](#build)
      * [migrate](#migrate)
      * [migrate](#migrate-1)
      * [make](#make)
         * [config](#config)
         * [key](#key)
         * [controller](#controller)
         * [view](#view)
         * [migration](#migration)
         * [model](#model)
            * [Create child domain model in aggregate](#create-child-domain-model-in-aggregate)
         * [value object](#value-object)
         * [usecase](#usecase)
   * [Bash-completion](#bash-completion)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Fri Sep 23 13:13:59 UTC 2022 -->

<!--te-->

## Introduction
`ducere` is a CLI tool for Basolato framework such as `rake`/`php artisan`.

## Usages

### new
Create new project
```
pwd
> /user/local/src
ducere new my_project
> Created project /user/local/src/my_project
```

```
pwd
> /user/local/src
mkdir my_project
cd my_project
ducere new .
> Created project /user/local/src/my_project
```

### serve
Run develop server with hot reload

```sh
Usage:
  serve [optional-params] 
Run dev application with hot reload
Options:
  -h, --help                  print this cligen-erated help
  --help-syntax               advanced: prepend,plurals,..
  --version      bool  false  print version
  -p=, --port=   int   5000   set port
  -f, --force    bool  false  set force
  --httpbeast    bool  false  set httpbeast
  --httpx        bool  false  set httpx
```

```sh
ducere serve
```
The default port is 5000. If you want to change it, specify with option `-p`

```sh
ducere serve -p:8000
```

You can change host by editing env of `config.nims`
```sh
putEnv("HOST", "127.0.0.2")
```

You can choose [httpbeast](https://github.com/dom96/httpbeast) or [httpx](https://github.com/ringabout/httpx) insted of [asynchttpserver](https://nim-lang.org/docs/asynchttpserver.html) for basolato core server.
```sh
ducere serve --httpbeast
ducere serve --httpx
```

### build
Compiling for production.  
By default, it will be compiled to run 5000 port and single thread.

```sh
Usage:
  build [optional-params] [args: string...]
Build for production.
Options:
  -h, --help                     print this cligen-erated help
  --help-syntax                  advanced: prepend,plurals,..
  --version      bool    false   print version
  -p=, --port=   string  "5000"  set port
  -f, --force    bool    false   set force
  --httpbeast    bool    false   set httpbeast
  --httpx        bool    false   set httpx
```

You can choose [httpbeast](https://github.com/dom96/httpbeast) or [httpx](https://github.com/ringabout/httpx) insted of [asynchttpserver](https://nim-lang.org/docs/asynchttpserver.html) for basolato core server.
```sh
ducere serve --httpbeast
ducere serve --httpx
```

### migrate
```sh
ducere migrate
```
This is a alias for `nim c -r migrations/migrate`

### migrate
```sh
ducere migrate --reset --seed
```
This is an alias for `nim c -r database/migrations/migrate`

- options
  - `--reset`
   Drop tables and re-migrate.
  - `--seed`
   Execute `database/seeders/seed` after migration.

### make
Create new file

#### config
Create `config.nims` for database connection, logging, session-timeout configuation.
```sh
ducere make config
```

#### key
Generate new `SECRET_KEY` in `.env`
```sh
ducere make key
```

#### controller
Create new controller
```sh
ducere make controller user
>> app/http/controllers/user_controller.nim

ducere make controller sample/user
>> app/http/controllers/sample/user_controller.nim

ducere make controller sample/sample2/user
>> app/http/controllers/sample/sample2/user_controller.nim
```

#### view
Create new view template.
`layout` is a part of components. `page` is a view that called by controller.

```sh
ducere make layout buttons/success_button
>> app/http/views/layouts/buttons/success_button_view.nim
```

```sh
ducere make page login
>> app/http/views/pages/login_view.nim
```

It you add `--scf` option for view creating command, SCF view will be created.
```sh
ducere make layout buttons/success_button --scf
ducere make page login --scf
```

#### migration
Create new migration file
```sh
ducere make migration create_user
>> migrations/migration20200219134020create_user.nim
```

#### model

- Create top level domain model(=aggregate)

```sh
ducere make model circle
```

in app/models
```
circle
├── circle_entity.nim
├── circle_repository_interface.nim
├── circle_service.nim
└── circle_value_objects.nim
```

in app/queries
```
circle
└── circle_query.nim
```

in app/repositories
```
circle
└── circle_repository.nim
```


##### Create child domain model in aggregate
```sh
ducere make model circle/user
```

in app/models
```
circle
├── circle_entity.nim
├── circle_repository_interface.nim
├── circle_service.nim
├── circle_value_objects.nim
└── user
    ├── user_entity.nim
    ├── user_service.nim
    └── user_value_objects.nim
```

#### value object
Add new minimum value object boilerplate.  

```sh
ducere make vo {arg1} {arg2}
```

`arg1` specifies the name of the model to which the value object will be written. Ex: `app/core/models/{model}/{model}_value_object`.  
`arg2` is a name of value object which should be Camel Case.

```sh
ducere make vo circle CircleName
>> add CircleName in app/models/circle/circle_value_objects.nim

ducere make vo circle/user UserName
>> add UserName in app/models/circle/user/user_value_objects.nim
```

#### usecase
Create new usecase.  
At the same time, create `query service` and `query service interface`.

```sh
ducere make usecase sign signin
>> Updated app/di_container.nim
>> Created usecase in app/usecases/sign/signin_usecase.nim
>> Created query in app/data_stores/queries/sign/signin_query.nim
```

## Bash-completion

Clone this repository if you want to use `bash-completion` for `ducere`.

```sh
git clone https://github.com/itsumura-h/nim-basolato /path/to/nim-basolato
```

And add this shell script to `~/.bashrc`.

```sh
source /path/to/nim-basolato/completions/bash/ducere
```

Or, copy completion file to directory.

```sh
sudo install -o root -g root -m 0644 /path/to/nim-basolato/completions/bash/ducere /usr/share/bash-completion/completions/ducere
```
