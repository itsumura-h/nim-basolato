decere command
===
[back](../README.md)

`ducere` is a CLI tool for Basolato framework such as `rails new`/`php artisan`.

# new
Create new project
```
ducere new
```

# make
Create new file

## config
Create `config.nims` for database connection, logging, session-timeout configuation.
```
ducere make config
```

## controller
Create new controller  
```sh
ducere make controller User
>> app/controllers/UserController.nim

ducere make controller sample/User
>> app/controllers/sample/UserController.nim

ducere make controller sample/sample2/User
>> app/controllers/sample/sample2/UserController.nim
```

## migration
Create new migration file
```sh
ducere make migration createUser
>> migrations/migration20200219134020createUser.nim
```
