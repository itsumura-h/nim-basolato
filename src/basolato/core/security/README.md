# security

`src/basolato/core/security` は、セッション、Cookie、CSRF、JWT、乱数生成をまとめたセキュリティ基盤レイヤである。  
特にセッション系は `Context -> Session -> SessionDb -> 実ストア` の段階構造になっている。

## ディレクトリ構造

```text
security/
├── context.nim
├── cookie.nim
├── csrf_token.nim
├── jwt.nim
├── random_string.nim
├── session.nim
├── session_db.nim
└── session_db/
    ├── json_session_db.nim
    ├── redis_session_db.nim
    ├── session_db_interface.nim
    └── libs/
        └── json_file_db.nim
```

## 依存関係

セッション管理の主要な依存方向は以下の通り。

```text
context
  -> session
    -> session_db
      -> session_db_interface
      -> json_session_db or redis_session_db
        -> random_string
        -> json_file_db (json 実装時のみ)

csrf_token
  -> session

session
  -> random_string
  -> cookie
  -> session_db

cookie
  -> settings

jwt
  -> logger
  -> nimcrypto
```

補足:
- `session_db.nim` は `SESSION_TYPE` によって `json_session_db.nim` または `redis_session_db.nim` を切り替える。
- `context.nim` は HTTP リクエストと Params を保持しつつ、セッション操作の窓口になる。
- `csrf_token.nim` は `Session` 上に保存されたトークンと、View 向け hidden input 表現を橋渡しする。

## 各ファイルの役割

### `context.nim`

- リクエストスコープのセキュリティコンテキスト
- `Request`、`Params`、`Option[Session]` を内部保持する
- `context.session` は `ContextSession` を返し、セッション値ストアへの低レベル操作（`get` `set` `isSome` `delete` `getToken` `updateCsrfToken` `destroy`）を提供する。利用者は `Option[Session]` を意識しない
- `context.updateCsrfToken` はセッション上の CSRF トークンを再生成し、その値を Context にも保持する
- `login` `logout` `isLogin` `setFlash` `getFlash` など、認証・フラッシュ・バリデーションエラー表示といった高レベル操作は `Context` 直下に残す
- `globalContext` を通じたグローバル参照口も提供する

### `session.nim`

- セッションオブジェクト本体
- 実データ保存先は `SessionDb` に委譲し、自身は薄いラッパーとして動作する
- `set/get/delete/destroy` などのセッション操作を提供する
- CSRF トークンをセッション内で更新し、生成した値を呼び出し側へ返す

### `session_db.nim`

- セッション永続化の抽象化レイヤ
- `ISessionDb` を内部に保持し、呼び出し側に保存先の違いを意識させない
- `SESSION_TYPE` に応じて JSON ファイル実装か Redis 実装を切り替える
- `checkSessionIdValid` により既存セッションIDの妥当性確認も吸収する
- 実装型は `new` で生成した直後にのみ `toInterface` に渡し、コピーしない

### `session_db/session_db_interface.nim`

- セッションストア実装の共通インターフェース定義
- `getToken` `setStr` `setJson` `getRows` `destroy` などの必須操作を tuple で表現する
- 上位レイヤはこの契約にだけ依存する
- `toInterface` は実装オブジェクトをクロージャで捕捉するため、**JsonSessionDb / RedisSessionDb をコピーしないこと**（コピー先から呼んでも元の実装を参照し続ける）

### `session_db/json_session_db.nim`

- JSON ファイルベースのセッションストア実装
- `JsonFileDb` を内部に持ち、行単位の JSON レコードとしてセッションを永続化する
- セッションIDが空、または無効な場合は新規IDを発行する
- ローカル開発や軽量構成向けの実装である
- **注意:** search / sync / destroy は O(n) のため、本番・大規模では Redis 実装を推奨する

### `session_db/redis_session_db.nim`

- Redis ベースのセッションストア実装
- Redis hash にセッションデータを保存する
- TTL を `SESSION_TIME` に合わせて付与し、期限付きセッションとして扱う
- セッションIDが不正なら新しいIDを発行する
- 本番寄りの共有セッション基盤として使う想定である

### `session_db/libs/json_file_db.nim`

- JSON ファイル永続化の低レベルユーティリティ
- ファイル読書き、行検索、同期、削除を担当する（いずれも O(n)）
- `JsonSessionDb` 専用の内部ストレージ部品であり、上位レイヤが直接依存する層ではない
- 本番・大規模利用時は Redis 実装を推奨する

### `cookie.nim`

- Cookie の読み書きと `Set-Cookie` 文字列生成を担当する
- `SameSite` `Secure` `HttpOnly` `Domain` `Path` などの属性を構築する
- 受信Cookieの解析と、送信Cookieの蓄積を `Cookies` 型で管理する
- セッションIDをクッキーで扱う場合の土台となる

### `csrf_token.nim`

- CSRF トークンの値オブジェクト
- セッションに保存されたトークンとの照合を行う
- View で hidden input として埋め込む文字列表現を提供する
- MPA のフォーム送信時に必要な橋渡し層である

### `jwt.nim`

- JWT の encode / decode を担当する
- 現状は HMAC 系アルゴリズムを中心に扱う
- セッションベース認証とは独立した、API 認証向けの別系統ユーティリティである

### `random_string.nim`

- セキュアなランダム文字列生成ユーティリティ
- セッションIDやCSRFトークンの生成元として使われる
- `/dev/urandom` ベースの `secureRandStr` と、汎用用途の `randStr` を提供する

## レイヤ別の責務整理

### 1. リクエスト境界

- `context.nim`
- `cookie.nim`
- `csrf_token.nim`

HTTP リクエスト/レスポンスと直接接続される層であり、コントローラーやミドルウェアから利用される。

### 2. セッションアプリケーション層

- `session.nim`
- `session_db.nim`
- `session_db/session_db_interface.nim`

セッション操作のユースケースと、保存先抽象化を担う。

### 3. インフラ層

- `session_db/json_session_db.nim`
- `session_db/redis_session_db.nim`
- `session_db/libs/json_file_db.nim`

実際の永続化先を扱う実装層である。

### 4. 補助セキュリティユーティリティ

- `jwt.nim`
- `random_string.nim`

セッション以外の認証方式や、秘密値生成を支える補助部品である。

## 設計上の読み方

- Cookie はクライアントとのセッションID受け渡しを担当する
- Session はアプリケーションから見たセッション操作 API を担当する
- SessionDb は保存先の違いを吸収する
- JsonSessionDb / RedisSessionDb は実際の保存先に応じた実装である
- Context はそれらをリクエスト単位に束ねる入口である

このため、上位のコントローラーやミドルウェアは原則として `Context` または `Session` を触ればよく、JSON ファイルや Redis の詳細に直接依存しない構造になっている。
