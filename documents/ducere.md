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
         * [migration](#migration)

<!-- Added by: jiro4989, at: 2020年  3月 30日 月曜日 08:16:04 JST -->

<!--te-->

## new
Create new project
```
ducere new
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

### migration
Create new migration file
```sh
ducere make migration createUser
>> migrations/migration20200219134020createUser.nim
```
