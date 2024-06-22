設定
===
[戻る](../../README.md)

目次
<!--ts-->


<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 10:32:17 UTC 2024 -->

<!--te-->

## イントロダクション
Basolatoの設定は、3つの方法で定義されます。
- `config.nims`に書かれ、git管理され、コンパイル時に呼ばれるもの
- 開発時は`.env`に、本番稼働時はサーバーの環境変数に定義され、git管理されず、実行時に呼ばれるもの
- `Settings.new()`のインスタンスに記録され、git管理され、実行時に呼ばれるもの


## コンパイル時に呼ばれる環境変数 (config.nims)
変更を適用するには再度コンパイルする必要があります。

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

### USE_LIBSASS :string = "false"
`libsaas`を有効にし、ビューの中でSASS/SCSSを使えるようにするかどうかです。

サンプル config.nims
```nim
putEnv("DB_SQLITE", $true) # "true" or "false"
# putEnv("DB_POSTGRES", $true) # "true" or "false"
# putEnv("DB_MYSQL", $true) # "true" or "false"
# putEnv("DB_MARIADB", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("USE_LIBSASS", $false) # "true" or "false"
```

## 実行時に呼ばれる環境変数 (.env)
変更を適用するには再度アプリケーションを起動してください。

### SECRET_KEY :string
セッションIDなどの暗号化に使われる100文字のキーです。

### DB_DATABASE :string
接続先RDBのデータベース名です。

### DB_USER :string
RDBに接続するためのユーザー名です。

### DB_PASSWORD :string
RDBに接続するためのパスワードです。

### DB_HOST :string
接続先RDBのホストです。Sqliteを使う場合にはファイルの絶対パス、MySQL, PostgreSQLを使う場合には`ホスト`を指定してください。

### DB_PORT :int
接続先RDBの場所です。Sqliteを使う場合には空、MySQL, PostgreSQLを使う場合には`ポート番号`を指定してください。

### DB_MAX_CONNECTION :int
RDBに非同期接続する時に作るコネクションプールの数です。  
アプリケーションをマルチスレッドで動かす場合には、「接続可能数 / スレッド数」になるようにしてください。

### SESSION_DB_PATH :string
接続先セッションDBの場所です。  
ファイルセッションを使う場合にはファイルの絶対パスを、Redisを使う場合には`ホスト:ポート`を設定してください。

### COOKIE_DOMAINS :string
クッキーを発行する対象ドメインを設定してください。

サンプル .env
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
DB_TIMEOUT=30 # secounds

# Session db
# Session type, file or redis, is defined in config.nims
SESSION_DB_PATH="./session.db" # Session file path or redis host:port. ex:"127.0.0.1:6379"

COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"
```

## Settingオブジェクトで設定するもの
実行時に呼ばれ、環境変数に設定すべき値のような機密情報でないものは、`Settings.new()`で定義します。

### HOST :string = "0.0.0.0"
起動するサーバーのホスト名です。

### PORT :int = 8000
起動するサーバーのポート番号です。

### LOG_TO_CONSOLE :bool = true
ログをターミナルに表示するなら`true`を、しないなら`false`を設定してください。

### LOG_TO_FILE :bool = true
ログをファイル出力するなら`true`を、しないなら`false`を設定してください。

### ERROR_LOG_TO_FILE :bool = true
エラーログをファイル出力するなら`true`を、しないなら`false`を設定してください。

### LOG_DIR :string = getCurrentDir() / "logs"
ログ出力先ディレクトリの絶対パスです。

### SESSION_TIME :int = 120
セッションタイムアウトになる期限を分で設定してください。

### SESSION_EXPIRE_ON_CLOSE: bool = false
ブラウザを閉じた時にセッションを自動的に削除する場合はtrueを設定してください。

### LOCALE :string = "en"
バリデーションメッセージを表示する言語です。

|言語|環境変数|
|---|---|
|英語|en|
|日本語|ja|


サンプルコード main.nim
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
