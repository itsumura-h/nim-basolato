Ducereコマンド
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [Ducereコマンド](#ducereコマンド)
      * [イントロダクション](#イントロダクション)
      * [使い方](#使い方)
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
               * [最上位のドメインモデル（＝集約）を作る](#最上位のドメインモデル集約を作る)
               * [集約の子要素のドメインモデルを作る](#集約の子要素のドメインモデルを作る)
            * [usecase](#usecase)
            * [value object](#value-object)
      * [Bash-completion](#bash-completion)

<!-- Added by: root, at: Wed Sep  8 16:13:12 UTC 2021 -->

<!--te-->

## イントロダクション
`ducere`はRuby on Railsにおける`rake`、Laravelにおける`php artisan`のようなBasolatoフレームワークのCLIツールです。

## 使い方

### new
新しくプロジェクトを作ります
```sh
pwd
> /user/local/src
ducere new my_project
> Created project /user/local/src/my_project
```

```sh
pwd
> /user/local/src
mkdir my_project
cd my_project
ducere new .
> Created project /user/local/src/my_project
```

### serve
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

ホットリロードが有効になった開発用サーバーを立ち上げます。
```sh
ducere serve
```

デフォルトでは5000番ポートで起動します。`-p`のオプションを付けることで起動ポートを変更できます。
```sh
ducere serve -p:8000
```

ホストを設定するには`.env`の環境変数に追記してください。
```sh
HOST="127.0.0.2"
```

### build
本番環境用にプロジェクトをビルドします。
何もオプションを付けない場合、5000番ポートを使い、実行したコンピューターのコア数分マルチスレッドで起動するようになっています。
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

```sh
ducere build
./main
>> Starting 4 threads
>> Listening on 0.0.0.0:5000
```

複数のポートを指定した場合、シングルスレッドで、それぞれのポートを使って起動する実行バイナリが複数出力されます。

**マルチスレッドでの起動はバグの危険性があります。そのためシングルスレッドで起動し、Nginxでロードバランシングさせることを推奨しています。**

```sh
ducere build -p:5000,5001,5002
>> generated main5000, main5001, main5002

./main5000
>> Starting 1 thread
>> Listening on 0.0.0.0:5000

./main5001
>> Starting 1 thread
>> Listening on 0.0.0.0:5001
```

以下は本番環境で動かすためのNginxのサンプルです。

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
ducere migrate --reset --seed
```
これは`nim c -r database/migrations/migrate`のエイリアスです

- オプション
  - `--reset`
   テーブルを破棄してマイグレーションし直します
  - `--seed`
   マイグレーション実行後に`database/seeders/seed`を実行します


### make
予め雛形が書かれた新しいファイルを作ります。

#### config

DBコネクション、ログ、セッションタイムなどを定義するための`config.nims`、`.env`のファイルを作ります。
```
ducere make config
```

#### controller

コントローラーを作ります。
```sh
ducere make controller user
>> app/controllers/user_controller.nim

ducere make controller sample/user
>> app/controllers/sample/user_controller.nim

ducere make controller sample/sample2/user
>> app/controllers/sample/sample2/user_controller.nim
```

#### view

画面を描画するためのビューテンプレートを作ります。  
`layout`はコンポーネントのパーツ、`page`は実際にコントローラーから呼び出されるビューです。

```sh
ducere make layout buttons/success_button
>> resources/layouts/buttons/success_button_view.nim
```

```sh
ducere make page login
>> resources/pages/login_view.nim
```

#### migration
マイグレーションファイルを作ります。

```sh
ducere make migration create_user
>> migrations/migration20200219134020create_user.nim
```

#### model
##### 最上位のドメインモデル（＝集約）を作る
ドメインモデルを作ります。

```sh
ducere make model circle
```

in app/core/models
```
circle
├── circle_entity.nim
├── circle_repository_interface.nim
├── circle_service.nim
└── circle_value_object.nim
```

in app/repositories
```
circle
└── circle_rdb_repository.nim
```

##### 集約の子要素のドメインモデルを作る
```sh
ducere make model circle/user
```

in app/core/models
```
circle
├── circle_entity.nim
├── circle_repository_interface.nim
├── circle_service.nim
├── circle_value_object.nim
└── user
    ├── user_entity.nim
    └── user_service.nim
```

#### usecase
ユースケースを作ります。

```sh
ducere make usecase login
>> app/domain/usecases/login_usecase.nim
```

#### value object
値オブジェクトの最小の雛形を追加します。

```sh
ducere make valueobject {引数1} {引数2}
```

`引数1`はキャメルケースの値オブジェクトの名前です。  
`引数2`は`app/domain/models`内の集約名です。

```sh
ducere make valueobject UserName user
>> add UserName in app/domain/models/user/user_value_objects.nim
```

## Bash-completion

もし `ducere` でBashのタブ補完機能を使いたければ、この手順を実施してください。
まず、このリポジトリを任意の場所に clone します。

```sh
git clone https://github.com/itsumura-h/nim-basolato /path/to/nim-basolato
```

次に、以下のシェルを `~/.bashrc` に追記します。

```sh
source /path/to/nim-basolato/completions/bash/ducere
```

あるいは、 `bash-completion` 用の所定の場所にファイルをコピーします。

```sh
sudo install -o root -g root -m 0644 /path/to/nim-basolato/completions/bash/ducere /usr/share/bash-completion/completions/ducere
```