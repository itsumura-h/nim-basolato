Ducereコマンド
===
[戻る](../../README.md)

目次
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
         * [key](#key)
         * [controller](#controller)
         * [view](#view)
         * [migration](#migration)
         * [model](#model)
         * [value object](#value-object)
         * [usecase](#usecase)
   * [Bash-completion](#bash-completion)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 11:26:26 UTC 2024 -->

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
  -f, --force    bool  false  set force
  --httpbeast    bool  false  set httpbeast
  --httpx        bool  false  set httpx
```

ホットリロードが有効になった開発用サーバーを立ち上げます。
```sh
ducere serve
```

デフォルトでは5000番ポートで起動します。`-p`のオプションを付けることで起動ポートを変更できます。
```sh
ducere serve -p:8000
```

ホストを設定するには`config.nims`の環境変数を編集してください。
```sh
putEnv("HOST", "127.0.0.2")
```

アプリケーションサーバーのコアを[asynchttpserver](https://nim-lang.org/docs/asynchttpserver.html)の代わりに[httpbeast](https://github.com/dom96/httpbeast), [httpx](https://github.com/ringabout/httpx)を使うこともできます。
```sh
ducere serve --httpbeast
ducere serve --httpx
```

### build
本番環境用にプロジェクトをビルドします。
```sh
Usage:
  build [optional-params] [args: string...]
Build for production.
Options:
  -h, --help                           print this cligen-erated help
  --help-syntax                        advanced: prepend,plurals,..
  --version          bool    false     print version
  -p=, --port=       int     5000      set port
  -w=, --workers=    uint    0         set workers
  -f, --force        bool    false     set force
  --httpbeast        bool    false     set httpbeast
  --httpx            bool    false     set httpx
  -a, --autoRestart  bool    false     set autoRestart
  -o=, --optimize=   string  "memory"  memory|speed
```
何もオプションを付けない場合、5000番ポートを使い、シングルスレッド・マルチプロセスで起動します。  
ビルドすると`startServer.sh`というシェルスクリプトが作られるので、これを実行することでサーバーを起動します。

```sh
ducere build
./startServer.sh

> running 4 processes
> Basolato uses config file '/basolato/.env'
> Basolato uses config file '/basolato/.env'
> Basolato uses config file '/basolato/.env'
> Basolato uses config file '/basolato/.env'
> Basolato based on asynchttpserver listening on 0.0.0.0:8000
> Basolato based on asynchttpserver listening on 0.0.0.0:8000
> Basolato based on asynchttpserver listening on 0.0.0.0:8000
> Basolato based on asynchttpserver listening on 0.0.0.0:8000
```

デフォルトでは5000番ポートで起動します。`-p`のオプションを付けることで起動ポートを変更できます。
```sh
ducere build -p:8000
```

`workers`をセットすることで動かすプロセス数を設定できます。デフォルトは0で、ビルド環境のCPUのコア数分プロセスを作ります。
```sh
ducere build --workers=2
  or
ducere build -w=2
```

`autoRestart`をセットすることで、アプリケーションが何らかのエラーで落ちた時に自動で再起動するシェルを出力します。
```sh
# autoRestart = false
./main & ./main & ./main & ./main

# autoRestart = true
while [ 1 ]; do
  ./main & \
  ./main & \
  ./main & \
  ./main
done
```

ホストを設定するには`config.nims`の環境変数を編集してください。
```sh
putEnv("HOST", "127.0.0.2")
```

アプリケーションサーバーのコアを[asynchttpserver](https://nim-lang.org/docs/asynchttpserver.html)の代わりに[httpbeast](https://github.com/dom96/httpbeast), [httpx](https://github.com/ringabout/httpx)を使うこともできます。
```sh
ducere build --httpbeast
ducere build --httpx
```

optimizeオプションにはmemoryかspeedを選択することができます。  
もしmemoryを選んだ時には `ORC` が使われ、メモリ消費が少なくなります。speedを選んだ時には `markAndSweep` が使われ、スループットがより多くなるようになります。

```sh
ducere build --optimize=memory
> nim c --mm:orc -d:useMalloc ... main

ducere build --optimize=speed
> nim c --mm:markAndSweep -d:useRealtimeGC ... main
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
```sh
ducere make config
```

#### key
新しい`SECRET_KEY`を`.env`の中に作ります
```sh
ducere make key
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
>> app/http/views/layouts/buttons/success_button_view.nim
```

```sh
ducere make page login
>> app/http/views/pages/login_view.nim
```

ビューを作るコマンドに `--scf` を付けると、SCFでのビューファイルが作られます。
```sh
ducere make layout buttons/success_button --scf
ducere make page login --scf
```

#### migration
マイグレーションファイルを作ります。

```sh
ducere make migration create_user
>> migrations/migration20200219134020create_user.nim
```

#### model
- 最上位のドメインモデル（＝集約）を作る

ドメインモデルを作ります。

```sh
ducere make model circle
```

in app/models
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

- 集約の子要素のドメインモデルを作る

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
値オブジェクトの最小の雛形を追加します。

```sh
ducere make vo {引数1} {引数2}
```

`引数1`は`app/models`内のモデル名です。  
`引数2`はキャメルケースの値オブジェクトの名前です。

```sh
ducere make vo circle CircleName
>> add CircleName in app/models/circle/circle_value_objects.nim

ducere make vo circle/user UserName
>> add UserName in app/models/circle/user/user_value_objects.nim
```

#### usecase
ユースケースを作ります。  
同時にクエリサービスとクエリインターフェースも作られます。

```sh
ducere make usecase {引数1} {引数2}
```

`引数1`は`app/usecases`内のパッケージ名です。  
`引数2`はキャメルケースのユースケースの名前です。

```sh
ducere make usecase sign signin
>> Updated app/di_container.nim
>> Created usecase in app/usecases/sign/signin/signin_usecase.nim
>> Created query in app/data_stores/queries/sign/signin_query.nim
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
