環境変数ヘルパー
===
[戻る](../../README.md)

目次

<!--ts-->
* [環境変数ヘルパー](#環境変数ヘルパー)
   * [イントロダクション](#イントロダクション)
   * [`env.nim` の役割](#envnim-の役割)
   * [利用できるヘルパー](#利用できるヘルパー)
   * [典型的な使い方](#典型的な使い方)
   * [テスト時の注意](#テスト時の注意)
   * [移行時の指針](#移行時の指針)

<!--te-->

## イントロダクション
`env.nim` は、Basolato で環境変数を読むための単一の入口です。

環境変数の取得口を 1 箇所に集約し、必須値が未設定または不正な場合は起動直後に fail-fast することを目的にしています。

## `env.nim` の役割
共通実装は [`src/basolato/core/env.nim`](../../src/basolato/core/env.nim) にあります。

このモジュールは次の責務を持ちます。

- カレントディレクトリの `.env` を import 時に読み込む
- 必須の環境変数を共通 API で取得する
- bool / int / 列挙値のような制約付き値をまとめて parse する
- 必須値が未設定、または不正な値なら即座に例外で停止する

アプリ固有の型付き値は、[`examples/realworld/config/env.nim`](../../examples/realworld/config/env.nim) のように config 層で定義します。

## 利用できるヘルパー
ヘルパーは必要最小限にしています。

- `loadDotEnv(path = getCurrentDir() / ".env")`
- `requireEnv(name: string): string`
- `optionalEnv(name: string, defaultValue: string): string`
- `parseBoolEnv(raw: string): bool`
- `parseIntEnv(name, raw: string): int`
- `parseSessionType(raw: string): SessionType`
- `requireBoolEnv(name: string): bool`
- `optionalBoolEnv(name: string, defaultValue: bool): bool`
- `requireIntEnv(name: string): int`
- `optionalIntEnv(name: string, defaultValue: int): int`

アプリ固有の enum は config 層で parser を定義し、その層で型付きの公開値に変換してください。

## 典型的な使い方
起動できないと困る値には `requireEnv` を使います。

```nim
import std/strutils
import basolato/core/env

type AppEnvType* = enum
  Test = "test"
  Develop = "develop"
  Staging = "staging"
  Production = "production"

func parseAppEnv*(raw: string): AppEnvType =
  case raw.strip().toLowerAscii()
  of "test":
    AppEnvType.Test
  of "develop":
    AppEnvType.Develop
  of "staging":
    AppEnvType.Staging
  of "production":
    AppEnvType.Production
  else:
    raise newException(ValueError, "APP_ENV must be test|develop|staging|production")

let APP_ENV* = parseAppEnv(optionalEnv("APP_ENV", "develop"))
let SECRET_KEY* = requireEnv("SECRET_KEY")
let DB_URL* = requireEnv("DB_URL")
```

アプリケーション側では、その公開値だけを使います。

```nim
import ./env
import ./database

if APP_ENV == AppEnvType.Test:
  discard

let rdb* = dbopen(PostgreSQL, DB_URL)
```

## テスト時の注意
`env.nim` は module import 時に値を評価することがあるため、依存モジュールを import する前に必要な環境変数を設定してください。

テストで一時的な値が必要な場合は、テストファイル内で `putEnv(...)` するか、実行コマンド側で `--putenv` を使うと安全です。

## 移行時の指針
既存コードを `env.nim` に寄せるときは、次の順番が扱いやすいです。

1. `SECRET_KEY` や `DB_URL` のような起動時必須値から移す
2. 直接の `getEnv(...)` を config 層の import に置き換える
3. 値の取り得る範囲が狭いものだけ typed parser を追加する
4. default を置く場合は、本当に安全な値だけに限定する
