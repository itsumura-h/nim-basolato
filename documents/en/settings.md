Settings
===
[back](../../README.md)

Table of Contents

<!--ts-->
- [Settings](#settings)
  - [Introduction](#introduction)
  - [Environment variables called at compile time (config.nims)](#environment-variables-called-at-compile-time-confignims)
    - [DB\_SQLITE :string = "true"](#db_sqlite-string--true)
    - [DB\_POSTGRES :string = "false"](#db_postgres-string--false)
    - [DB\_MYSQL :string = "false"](#db_mysql-string--false)
    - [DB\_MARIADB :string = "false"](#db_mariadb-string--false)
    - [SESSION\_TYPE :string = "file"](#session_type-string--file)
    - [USE\_LIBSASS :string = "false"](#use_libsass-string--false)
  - [Environment variables called at runtime (.env)](#environment-variables-called-at-runtime-env)
    - [SECRET\_KEY :string](#secret_key-string)
    - [DB\_DATABASE :string = ""](#db_database-string--)
    - [DB\_USER :string = ""](#db_user-string--)
    - [DB\_PASSWORD :string = ""](#db_password-string--)
    - [DB\_HOST :string = "sqlite"](#db_host-string--sqlite)
    - [DB\_PORT :int = 5432](#db_port-int--5432)
    - [DB\_MAX\_CONNECTION :int = 1](#db_max_connection-int--1)
    - [SESSION\_DB\_PATH :string = getCurrentDir() / "session.db"](#session_db_path-string--getcurrentdir--sessiondb)
    - [COOKIE\_DOMAINS :string = ""](#cookie_domains-string--)
  - [Settings configured in the Settings object](#settings-configured-in-the-settings-object)
    - [HOST :string = "0.0.0.0"](#host-string--0000)
    - [PORT :int = 8000](#port-int--8000)
    - [LOG\_TO\_CONSOLE :bool = true](#log_to_console-bool--true)
    - [LOG\_TO\_FILE :bool = true](#log_to_file-bool--true)
    - [ERROR\_LOG\_TO\_FILE :bool = true](#error_log_to_file-bool--true)
    - [LOG\_DIR :string = getCurrentDir() / "logs"](#log_dir-string--getcurrentdir--logs)
    - [SESSION\_TIME :int = 120](#session_time-int--120)
    - [SESSION\_EXPIRE\_ON\_CLOSE: bool = false](#session_expire_on_close-bool--false)
    - [LOCALE :string = "en"](#locale-string--en)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Fri Dec 22 21:20:33 UTC 2023 -->

<!--te-->

## Introduction
Basolato settings are defined in three ways:

- Written in `config.nims`, managed by git, and called at compile time
- Defined in `.env` during development or in server environment variables during production, not managed by git, and called at runtime
- Recorded in an instance of `Settings.new()`, managed by git, and called at runtime

## Environment variables called at compile time (config.nims)
Changes require recompilation to take effect.

### DB_SQLITE :string = "true"
Whether to connect to Sqlite.

### DB_POSTGRES :string = "false"
Whether to connect to PostgreSQL.

### DB_MYSQL :string = "false"
Whether to connect to MySQL.

### DB_MARIADB :string = "false"
Whether to connect to MariaDB.

### SESSION_TYPE :string = "file"
Type of session DB. Either file or redis.

### USE_LIBSASS :string = "false"
Whether to enable libsaas and allow the use of SASS/SCSS in views.

Sample config.nims
```nim
nimCopyputEnv("DB_SQLITE", $true) # "true" or "false"
# putEnv("DB_POSTGRES", $true) # "true" or "false"
# putEnv("DB_MYSQL", $true) # "true" or "false"
# putEnv("DB_MARIADB", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("USE_LIBSASS", $false) # "true" or "false"
```

## Environment variables called at runtime (.env)
Restart the application to apply changes.

### SECRET_KEY :string
A 100-character key used for encrypting session IDs, etc.

### DB_DATABASE :string = ""
Database name of the target RDB.

### DB_USER :string = ""
Username for connecting to the RDB.

### DB_PASSWORD :string = ""
Password for connecting to the RDB.

### DB_HOST :string = "sqlite"
Host of the target RDB. Specify the absolute file path for Sqlite, or the `host` for MySQL and PostgreSQL.

### DB_PORT :int = 5432
Location of the target RDB. Leave empty for Sqlite, specify the `port number` for MySQL and PostgreSQL.

### DB_MAX_CONNECTION :int = 1
Number of connection pools created for asynchronous RDB connections.  
For multi-threaded applications, set this to "maximum connections / number of threads".

### SESSION_DB_PATH :string = getCurrentDir() / "session.db"
Location of the session DB.
Set the absolute file path for file sessions, or `host:port` for Redis.

### COOKIE_DOMAINS :string = ""
Set the target domains for issuing cookies.


Sample .env
```sh
# Secret
SECRET_KEY="GRzV3jfgN8BgFhtiyoLV1aTNE6Evh9r1GLkpBpUCpioXy6ifo10fEL846MTRrd3cpOHMKsYCs1hNQDDYJ3NEOs2mEPYTemU3iGnm"

# DB Connection
DB_DATABASE="database" # sqlite file path or database name
DB_USER="user"
DB_PASSWORD="password"
DB_HOST="127.0.0.1"  # host ip address
DB_PORT=5432 # postgres default...5432, mysql default...3306
DB_MAX_CONNECTION=95 # should be smaller than (DB max connection / running num processes)
DB_TIMEOUT=30 # seconds

# Session db
# Session type, file or redis, is defined in config.nims
SESSION_DB_PATH="./session.db" # Session file path or redis host:port. ex:"127.0.0.1:6379"

COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"
```

## Settings configured in the Settings object
Non-sensitive information that should be set at runtime but not in environment variables is defined in `Settings.new()`.

### HOST :string = "0.0.0.0"
Hostname of the server to start.

### PORT :int = 8000
Port number of the server to start.

### LOG_TO_CONSOLE :bool = true
Set to true to display logs in the terminal, false otherwise.

### LOG_TO_FILE :bool = true
Set to true to output logs to a file, false otherwise.

### ERROR_LOG_TO_FILE :bool = true
Set to true to output error logs to a file, false otherwise.

### LOG_DIR :string = getCurrentDir() / "logs"
Absolute path of the log output directory.

### SESSION_TIME :int = 120
Set the session timeout period in minutes.

### SESSION_EXPIRE_ON_CLOSE: bool = false
Set to true to automatically delete the session when the browser is closed.

### LOCALE :string = "en"
Language for displaying validation messages.

|Language|Environment Variable|
|---|---|
|English|en|
|Japanese|ja|

Sample code main.nim
```nim
import basolato

let routs = @[
  Route.get("/", example_controller.index)
]

let settings = Settings.new(
  host = "127.0.0.1",
  port = 8000,
  # Logging
  logToConsole = true,
  logToFile = false,
  errorLogToFile = false,
  logDir = "./logs",
  # Session db
  sessionTime = 120, # default 120, minutes of 2 hours
  sessionExpireOnClose = false,
  # other
  locale = "en",
)

serve(routes, settings)
```
