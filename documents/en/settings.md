Settings
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [Settings](#settings)
      * [Introduction](#introduction)
      * [Environment variables called at compile time](#environment-variables-called-at-compile-time)
         * [SECRET_KEY :string](#secret_key-string)
         * [DB_DRIVER :string = "sqlite"](#db_driver-string--sqlite)
         * [SESSION_TYPE :string = "file"](#session_type-string--file)
      * [Environment variables called at runtime](#environment-variables-called-at-runtime)
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
         * [HOST :string = "0.0.0.0"](#host-string--0000)
         * [LOCALE :string = "en"](#locale-string--en)

<!-- Added by: root, at: Mon Apr 12 06:15:58 UTC 2021 -->

<!--te-->

## Introduction
Basolato settings is defined as environment variables in those of `config.nims`, `.env`, `.env.local`, `~/.bash_rc`, `~/.bash_profile` and so on.  
Environment variables defined in `.env` can only be called at application runtime.  
You should set common settings for various environments in `.env`, and environment-specific or sensitive DB connection information in `.env.local`.  
Note that `config.nims` and `.env.local` are not Git-managed by `.gitignore`.

## Environment variables called at compile time
To apply changes, you have to do re-compile.

### SECRET_KEY :string
24 characters key which is used for encryption session id.

### DB_DRIVER :string = "sqlite"
RDB driver which your system uses. Options are `sqlite`, `mysql` or `postgres`.

### SESSION_TYPE :string = "file"
Session DB type which your system uses. Options are `file` or `redis`.

sample
```nim
putEnv("SECRET_KEY", "abcdefghijklmnopqrstuvwx")
putEnv("DB_DRIVER", "sqlite") # "sqlite" or "mysql" or "postgres"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
```

## Environment variables called at runtime
To apply changes, you have to re-run application.

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

### HOST :string = "0.0.0.0"
Hostname to run server.

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
# Session type is defined in config.nims
SESSION_DB_PATH="/root/project/session.db" # Session file path or redis host:port. ex:"127.0.0.1:6379"
SESSION_TIME=20160 # minutes of 2 weeks
ENABLE_ANONYMOUS_COOKIE=true # true or false
COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"

# Other options
HOST="127.0.0.1"
LOCALE=en
```

sample .env.local
```sh
# DB Connection
# DB type is defined in config.nims
DB_CONNECTION="/root/project/db.sqlite3" # sqlite file path or host:port
DB_USER=""
DB_PASSWORD=""
DB_DATABASE=""
DB_MAX_CONNECTION=95 # should be smaller than (DB max connection / running threads num)
```
