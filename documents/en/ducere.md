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

### build
Compiling for production.  
By default, it will be compiled to run 5000 port and multithreaded for the number of cores in your PC.

```sh
Usage:
  build [optional-params] [args: string...]
Build for production.
Options:
  -h, --help                       print this cligen-erated help
  --help-syntax                    advanced: prepend,plurals,..
  --version        bool    false   print version
  -p=, --ports=    string  "5000"  set ports
  -t=, --threads=  string  "off"   set threads
```

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

autorestart.sh
```sh
ducere build -p:5000,5001,5002,5003
while [ 1 ]; do
  ./main5000 & \
  ./main5001 & \
  ./main5002 & \
  ./main5003
done
```

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
