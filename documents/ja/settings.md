設定
===
[戻る](../../README.md)

目次
<!--ts-->
* [設定](#設定)
   * [イントロダクション](#イントロダクション)
   * [コンパイル時に呼ばれる環境変数 (config.nims)](#コンパイル時に呼ばれる環境変数-confignims)
      * [HOST :string = "0.0.0.0"](#host-string--0000)
      * [DB_SQLITE :string = "true"](#db_sqlite-string--true)
      * [DB_POSTGRES :string = "false"](#db_postgres-string--false)
      * [DB_MYSQL :string = "false"](#db_mysql-string--false)
      * [DB_MARIADB :string = "false"](#db_mariadb-string--false)
      * [SESSION_TYPE :string = "file"](#session_type-string--file)
      * [LIBSASS :string = "false"](#libsass-string--false)
   * [実行時に呼ばれる環境変数 (.env)](#実行時に呼ばれる環境変数-env)
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
<!-- Added by: root, at: Fri Dec 22 21:22:04 UTC 2023 -->

<!--te-->

## イントロダクション
Basolatoの設定は、`config.nims`、 `.env`、 `~/.bash_rc`、 `~/.bash_profile` などで環境変数として定義されています。  
`.env`に定義された環境変数は、アプリケーション実行時にしか呼ぶことはできません。  
`config.nims`にはビルド時の設定を、`.env`では環境固有のものや機密性の高いDBとの接続情報などを設定します。  
`.env`は`.gitignore`によってGit管理されないようになっています。

## コンパイル時に呼ばれる環境変数 (config.nims)
変更を適用するには再度コンパイルする必要があります。

### HOST :string = "0.0.0.0"
起動するサーバーのホスト名です。

### DB_SQLITE :string = "true"
`Sqlite`に接続するかどうかです。

### DB_POSTGRES :string = "false"
`PostgreSQL`に接続するかどうかです。

### DB_MYSQL :string = "false"
`MySQL`に接続するかどうかです。

### DB_MARIADB :string = "false"
`MariaDB`に接続するかどうかです。

### SESSION_TYPE :string = "file"
セッションDBの種類です。`file`、`redis`のいずれかになります。

### LIBSASS :string = "false"
`libsaas`を有効にし、ビューの中でSASS/SCSSを使えるようにするかどうかです。

サンプル config.nims
```nim
putEnv("HOST", "0.0.0.0")
putEnv("DB_SQLITE", $true) # "true" or "false"
# putEnv("DB_POSTGRES", $true) # "true" or "false"
# putEnv("DB_MYSQL", $true) # "true" or "false"
# putEnv("DB_MARIADB", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("LIBSASS", $false) # "true" or "false"
```

## 実行時に呼ばれる環境変数 (.env)
変更を適用するには再度アプリケーションを起動してください。

### SECRET_KEY :string
セッションIDなどの暗号化に使われる100文字のキーです。

### DB_CONNECTION :string = "sqlite"
接続先RDBの場所です。Sqliteを使う場合にはファイルの絶対パス、MySQL, PostgreSQLを使う場合には`ホスト:ポート`を指定してください。

### DB_USER :string = ""
RDBに接続するためのユーザー名です。

### DB_PASSWORD :string = ""
RDBに接続するためのパスワードです。

### DB_DATABASE :string = ""
接続先RDBのデータベース名です。

### DB_MAX_CONNECTION :int = 1
RDBに非同期接続する時に作るコネクションプールの数です。  
アプリケーションをマルチスレッドで動かす場合には、「接続可能数 / スレッド数」になるようにしてください。

---

### LOG_IS_DISPLAY :bool = true
ログをターミナルに表示するなら`true`を、しないなら`false`を設定してください。

### LOG_IS_FILE :bool = true
ログをファイル出力するなら`true`を、しないなら`false`を設定してください。

### LOG_IS_ERROR_FILE :bool = true
エラーログをファイル出力するなら`true`を、しないなら`false`を設定してください。

### LOG_DIR :string = getCurrentDir() / "logs"
ログ出力先ディレクトリの絶対パスです。

---

### SESSION_DB_PATH :string = getCurrentDir() / "session.db"
接続先セッションDBの場所です。  
ファイルセッションを使う場合にはファイルの絶対パスを、Redisを使う場合には`ホスト:ポート`を設定してください。

### SESSION_TIME :int = 20160
セッションタイムアウトになる期限を分で設定してください。

### ENABLE_ANONYMOUS_COOKIE :bool = true
匿名ユーザーにクッキーを発行するなら`true`を、しないなら`false`を設定してください。

### COOKIE_DOMAINS :string = ""
クッキーを発行する対象ドメインを設定してください。

### LOCALE :string = "en"
バリデーションメッセージを表示する言語です。

|言語|環境変数|
|---|---|
|英語|en|
|日本語|ja|

サンプル .env
```sh
# Logging
LOG_IS_DISPLAY=true # true or false
LOG_IS_FILE=true # true or false
LOG_IS_ERROR_FILE=true # true or false
LOG_DIR="/root/project/logs"

# Session db
# Session type, file or redis, is defined in config.nims
SESSION_DB_PATH="/root/project/session.db" # Session file path or redis host:port. ex:"127.0.0.1:6379"
SESSION_TIME=20160 # minutes of 2 weeks
ENABLE_ANONYMOUS_COOKIE=true # true or false
COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"

# Other options
LOCALE=ja
```
