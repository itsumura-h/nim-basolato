ducere command
===
[back](../README.md)

`ducere` is a CLI tool for Basolato framework such as `rails new`/`php artisan`.

Table of Contents

<!--ts-->
   * [ducere command](#ducere-command)
      * [new](#new)
      * [serve](#serve)
      * [make](#make)
         * [config](#config)
         * [controller](#controller)
         * [view](#view)
         * [migration](#migration)
         * [model](#model)
         * [usecase](#usecase)

<!-- Added by: root, at: Fri Jul 31 13:19:39 UTC 2020 -->

<!--te-->

## new
Create new project
```
ducere new my_project
```

## serve
Run develop server with hot reload
```
ducere serve
```

## make
Create new file

### config
Create `config.nims` for database connection, logging, session-timeout configuation.
```
ducere make config
```

### controller
Create new controller
```sh
ducere make controller user
>> app/controllers/user_controller.nim

ducere make controller sample/user
>> app/controllers/sample/user_controller.nim

ducere make controller sample/sample2/user
>> app/controllers/sample/sample2/user_controller.nim
```

### view
Create new view template
```sh
ducere make view pages/login
>> resources/pages/login_view.nim
```

### migration
Create make migration file
```sh
ducere make migration createUser
>> migrations/migration20200219134020createUser.nim
```

### model
create new domain model
```sh
ducere make model user
```
```
in app/domain/models

user
 ├── repositories
 │   └── user_rdb_repository.nim
 ├── user_entity.nim
 ├── user_repository_interface.nim
 └── user_service.nim
```

### usecase
Create new usecase
```sh
ducere make usecase login
>> app/domain/usecases/login_usecase.nim
```