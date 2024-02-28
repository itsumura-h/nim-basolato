Settings
===
[back](../../README.md)

Table of Contents

<!--ts-->
* [Settings](#settings)
   * [Introduction](#introduction)
   * [Environment variables called at compile time (config.nims)](#environment-variables-called-at-compile-time-confignims)
      * [HOST :string = "0.0.0.0"](#host-string--0000)
      * [DB_SQLITE :string = "true"](#db_sqlite-string--true)
      * [DB_POSTGRES :string = "false"](#db_postgres-string--false)
      * [DB_MYSQL :string = "false"](#db_mysql-string--false)
      * [DB_MARIADB :string = "false"](#db_mariadb-string--false)
      * [SESSION_TYPE :string = "file"](#session_type-string--file)
      * [LIBSASS :string = "false"](#libsass-string--false)
   * [Environment variables called at runtime (.env)](#environment-variables-called-at-runtime-env)
      * [SECRET_KEY :string](#secret_key-string)
      * [DB_CONNECTION :string = "sqlite"](#db_connection-string--sqlite)
      * [DB_USER :string = ""](#db_user-string--)
      * [DB_PASSWORD :string = ""](#db_password-string--)
      * [DB_DATABASE :string = ""](#db_database-string--)
      * [DB_MAX_CONNECTION :int = 1](#db_max_connection-int--1)
      * [LOG_IS_DISPLAY :bool = true](#log_is_display-bool--true)
      * [LOG_IS_FILE :bool = true](#log_is_file-bool--true)
      * [LOG_IS_ERROR_FILE :bool = true](#log_is_error_file-bool--true)
      * [LOG_DIR :string = getCurrentDir() / "logs"](#log_dir-string--getcurrentdir--logs)
      * [SESSION_DB_PATH :string = getCurrentDir() / "session.db"](#session_db_path-string--getcurrentdir--sessiondb)
      * [SESSION_TIME :int = 20160](#session_time-int--20160)
      * [ENABLE_ANONYMOUS_COOKIE :bool = true](#enable_anonymous_cookie-bool--true)
      * [COOKIE_DOMAINS :string = ""](#cookie_domains-string--)
      * [LOCALE :string = "en"](#locale-string--en)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Fri Dec 22 21:20:33 UTC 2023 -->

<!--te-->

## Introduction
Basolato settings is defined as environment variables in those of `config.nims`, `.env`, `~/.bash_rc`, `~/.bash_profile` and so on.  
Environment variables defined in `.env` can only be called at application runtime.  
You should set build time environments variables in `config.nims`, and environment-specific or sensitive DB connection information in `.env`.  
Note that `.env` are not Git-managed by `.gitignore`.

## Environment variables called at compile time (config.nims)
To apply changes, you have to do re-compile.

### HOST :string = "0.0.0.0"
Host name of the server to be started.

### DB_SQLITE :string = "true"
Whether to connect to `Sqlite` or not.

### DB_POSTGRES :string = "false"
Whether to connect to `PostgreSQL` or not.

### DB_MYSQL :string = "false"
Whether to connect to `MySQL` or not.

### DB_MARIADB :string = "false"
Whether to connect to `MariaDB` or not.

### SESSION_TYPE :string = "file"
Session DB type which your system uses. Options are `file` or `redis`.

### LIBSASS :string = "false"
Whether enable `libsaas` to use SASS/SCSS in view or not.

sample
```nim
putEnv("HOST", "0.0.0.0")
putEnv("DB_SQLITE", $true) # "true" or "false"
# putEnv("DB_POSTGRES", $true) # "true" or "false"
# putEnv("DB_MYSQL", $true) # "true" or "false"
# putEnv("DB_MARIADB", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("LIBSASS", $false) # "true" or "false"
```

## Environment variables called at runtime (.env)
To apply changes, you have to re-run application.

### SECRET_KEY :string
100 characters key which is used for encryption session id.

### DB_CONNECTION :string = "sqlite"
The location of the RDB to connect to, either the absolute path of the file if you are using Sqlite, or `host:port` if you are using MySQL or PostgreSQL.

### DB_USER :string = ""
The user name for connecting to the RDB.

### DB_PASSWORD :string = ""
The passsword for connecting to the RDB.

### DB_DATABASE :string = ""
The db name for connecting to the RDB.

### DB_MAX_CONNECTION :int = 1
The number of connection pools to create when making asynchronous connections to the RDB.  
If your application runs in multi-threaded mode, make sure that the number should be "number of possible connections / number of threads".

---

### LOG_IS_DISPLAY :bool = true
Set it to `true` if you want the log to be displayed on the terminal, or `false` if you don't want it.

### LOG_IS_FILE :bool = true
Set the value to `true` to output the log to a file, or `false` if you don't want to.

### LOG_IS_ERROR_FILE :bool = true
Set the value to `true` to output the error log to a file, or `false` if you don't want to.

### LOG_DIR :string = getCurrentDir() / "logs"
The absolute path of the log output destination directory.

---

### SESSION_DB_PATH :string = getCurrentDir() / "session.db"
The location of the session DB to connect to.  
Set the absolute path of the file if you use file sessions, or `host:port` if you use Redis.

### SESSION_TIME :int = 20160
Set a time limit in minutes for the session to time out.

### ENABLE_ANONYMOUS_COOKIE :bool = true
Set it to `true` if you want to generate cookies to anonymous users, or `false` if you don't.

### COOKIE_DOMAINS :string = ""
Set the target domain for issuing cookies.

### LOCALE :string = "en"
Language which you want to display validation message in.

|language|LOCALE|
|---|---|
|English|en|
|Japanese|ja|

sample .env
```sh
# Logging
LOG_IS_DISPLAY=true # true or false
LOG_IS_FILE=true # true or false
LOG_IS_ERROR_FILE=true # true or false
LOG_DIR="/root/project/logs"

# Session db
# Session type, file or redis, is defined in config.nims
SESSION_DB_PATH="/root/project/session.db" # Session file path or redis host:port. ex:"127.0.0.1:6379"
SESSION_TIME=120 # minutes of 2 hours
ENABLE_ANONYMOUS_COOKIE=true # true or false
COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"

# Other options
LOCALE=en
```
