クイックスタート
===
[戻る](../../README.md)

目次
<!--ts-->
* [クイックスタート](#クイックスタート)
   * [インストール](#インストール)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 11:26:23 UTC 2024 -->

<!--te-->

## インストール
Basolatoをインストールします。

```sh
nimble install https://github.com/itsumura-h/nim-basolato
```

プロジェクトを作成します。
```
ducere new sample_project
```

`sample_project`にプロジェクトディレクトリが作られるので、中に移動してください。

```sh
cd sample_project
```

開発用サーバーを起動します。
```
ducere serve
```

`http://0.0.0.0:8000`でサーバーが起動します。

ホスト名を指定する場合は、`.env`に追記してください。
```env
HOST="127.0.0.1"
```

ポートを指定する場合はコマンドオプションに追記してください。
ポート番号はコンパイル時に決定されます。
```sh
$ ducere serve -h
Usage:
  serve [optional-params] 
run application with hot reload
Options:
  -h, --help                  print this cligen-erated help
  --help-syntax               advanced: prepend,plurals,..
  --version      bool  false  print version
  -p=, --port=   int   5000   set port
```
```sh
ducere serve -p=8000
ducere serve --port=8000
```
