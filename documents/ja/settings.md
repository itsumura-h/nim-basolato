設定
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [設定](#設定)
      * [イントロダクション](#イントロダクション)
      * [コンパイル時に呼ばれる環境変数](#コンパイル時に呼ばれる環境変数)
         * [SECRET_KEY :string](#secret_key-string)
         * [DB_DRIVER :string = "sqlite"](#db_driver-string--sqlite)
         * [SESSION_TYPE :string = "file"](#session_type-string--file)
      * [実行時に呼ばれる環境変数](#実行時に呼ばれる環境変数)
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

<!-- Added by: root, at: Mon Apr 19 05:14:03 UTC 2021 -->

<!--te-->

## イントロダクション
Basolatoの設定は、`config.nims`、 `.env`、 `.env.local`、  `~/.bash_rc`、 `~/.bash_profile` などで環境変数として定義されています。  
`.env`、`.env.local`に定義された環境変数は、アプリケーション実行時にしか呼ぶことはできません。  
`.env`には様々な環境での共通設定を、`.env.local`には環境固有のものや機密性の高いDBとの接続情報などを設定してください。  
`config.nims`と`.env.local`は`.gitignore`によってGit管理されないようになっています。

## コンパイル時に呼ばれる環境変数
変更を適用するには再度コンパイルする必要があります。

### SECRET_KEY :string
セッションIDなどの暗号化に使われる24文字のキーです。

### DB_DRIVER :string = "sqlite"
接続先RDBの種類です。`sqlite`、`mysql`、`postgres`のいずれかになります。

### SESSION_TYPE :string = "file"
セッションDBの種類です。`file`、`redis`のいずれかになります。

サンプル config.nims
```nim
putEnv("SECRET_KEY", "abcdefghijklmnopqrstuvwx")
putEnv("DB_DRIVER", "sqlite") # "sqlite" or "mysql" or "postgres"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
```

## 実行時に呼ばれる環境変数
変更を適用するには再度アプリケーションを起動してください。

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

### HOST :string = "0.0.0.0"
サーバーを起動するホスト名です。

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
# Session type is defined in config.nims
SESSION_DB_PATH="/root/project/session.db" # Session file path or redis host:port. ex:"127.0.0.1:6379"
SESSION_TIME=20160 # minutes of 2 weeks
ENABLE_ANONYMOUS_COOKIE=true # true or false
COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"

# Other options
HOST="127.0.0.1"
LOCALE=ja
```

サンプル .env.local
```sh
# DB Connection
# DB type is defined in config.nims
DB_CONNECTION="/root/project/db.sqlite3" # sqlite file path or host:port
DB_USER=""
DB_PASSWORD=""
DB_DATABASE=""
DB_MAX_CONNECTION=95 # should be smaller than (DB max connection / running threads num)
```
