Ducere command
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [ducere command](#ducere-command)
      * [new](#new)
      * [serve](#serve)
      * [build](#build)
      * [migrate](#migrate)
      * [make](#make)
         * [config](#config)
         * [controller](#controller)
         * [view](#view)
         * [migration](#migration)
         * [model](#model)
         * [usecase](#usecase)
         * [value object](#value-object)

<!-- Added by: root, at: Sun Dec 27 18:20:21 UTC 2020 -->

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
```
ducere serve
```
The default port is 5000. If you want to change it, specify with option `-p`

```
ducere serve -p:8000
```

### build
Compiling for production.  
By default, it will be compiled to run 5000 port and multithreaded for the number of cores in your PC.

```
ducere build
./main
>> Starting 4 threads
>> Listening on port 5000
```

When you specify multi ports, it will be compiled to run each port and singlethreaded.

**Running with Multithreads is buggy. I recommand to compile for singlethreaded and run with nginx road balancer.**

```
ducere build -p:5000,5001,5002
>> generated main5000, main5001, main5002

./main5000
>> Starting 1 thread
>> Listening on port 5000

./main5001
>> Starting 1 thread
>> Listening on port 5001
```

Here is a sample to run in production environment.

nginx.conf
```nginx
worker_processes  auto;
worker_rlimit_nofile 150000;

events {
   worker_connections  65535;
   multi_accept on;
   use epoll;
}

http {
   access_log  /var/log/nginx/access.log  main;
   error_log   /var/log/nginx/error.log  info;
   tcp_nopush  on;

   upstream basolato {
      least_conn;
      server      127.0.0.1:5000;
      server      127.0.0.1:5001;
      server      127.0.0.1:5002;
      server      127.0.0.1:5003;
   }

   ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
   server {
      listen 443;
      ssl on;
      server_name www.example.com;
      ssl_certificate /etc/pki/tls/certs/example_com_combined.crt; # path to certification
      ssl_certificate_key /etc/pki/tls/private/example_com.key; # path to private key

      location / {
         proxy_pass http://basolato;
      }
   }
}
```

### migrate
```sh
ducere migrate
```
This is a alias for `nim c -r migrations/migrate`


### make
Create new file

#### config
Create `config.nims` for database connection, logging, session-timeout configuation.
```
ducere make config
```

#### controller
Create new controller
```sh
ducere make controller user
>> app/controllers/user_controller.nim

ducere make controller sample/user
>> app/controllers/sample/user_controller.nim

ducere make controller sample/sample2/user
>> app/controllers/sample/sample2/user_controller.nim
```

#### view
Create new view template.
`layout` is a part of components. `page` is a view that called by controller.

```sh
ducere make layout buttons/success_button
>> resources/layouts/buttons/success_button_view.nim
```

```sh
ducere make page login
>> resources/pages/login_view.nim
```

#### migration
Create new migration file
```sh
ducere make migration create_user
>> migrations/migration20200219134020create_user.nim
```

#### model
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

#### usecase
Create new usecase
```sh
ducere make usecase login
>> app/domain/usecases/login_usecase.nim
```

#### value object
Add new minimum value object boilerplate.  

```sh
ducere make valueobject {arg1} {arg2}
```

`arg1` is a name of value object which should be Camel Case.  
`arg2` is a relative path to value object file from `app/domain/models`.

example
```sh
ducere make valueobject UserName ./value_objects
>> add UserName in app/domain/models/value_objects
```
