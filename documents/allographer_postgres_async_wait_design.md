# allographer(PostgreSQL) 非同期待機改善 設計書

## 1. 背景

`httpbeast` / `httpx` 利用時のみ、DBクエリ待機が過大化し、`asynchttpserver` 利用時よりレスポンスが大幅に悪化する事象がある。

現状の `allographer` PostgreSQL実装は、libpq 非同期API (`PQsendQueryParams` + `PQisBusy`) を使っているが、待機ループ内で `sleepAsync(10)` を多用している。

- `allographer/query_builder/libs/postgres/postgres_impl.nim`
- `allographer/query_builder/models/postgres/postgres_exec.nim`

`httpbeast` / `httpx` 側イベントループとの組み合わせでは、タイマ駆動 (`sleepAsync`) の復帰遅延が発生しやすく、実質的に「非同期待機が粗いポーリング」になっている。

## 2. 問題の本質

### 2.1 クエリ結果待機

`postgres_impl.nim` は以下の流れで待機している。

1. `PQsendQueryParams`
2. `PQconsumeInput`
3. `PQisBusy == 1` の間 `await sleepAsync(10)`
4. 再度 2. へ

この方式は「タイマ精度とイベントループ実装」に性能が依存する。

### 2.2 プール空き待ち

`postgres_exec.nim` の `getFreeConn` も同様に `await sleepAsync(10)` で空き待ちしており、プール枯渇時に待機遅延が増幅される。

## 3. 設計目標

1. DB待機から `sleepAsync` ポーリングを除去する。
2. libpq ソケット可読/可書込イベントで待機する。
3. 接続プール空き待ちもイベント通知化し、タイマ依存を減らす。
4. 既存 API 互換（`dbOpen`, `table`, `select`, `find`, `update` など）を維持する。

## 4. 非目標

1. Query Builder APIの破壊的変更。
2. PostgreSQL 以外（MySQL/MariaDB/SQLite）への同時展開。
3. 複数OS向け最適化を初回で完全実装（まず Linux/Posix を主対象）。

## 5. 変更方針

## 5.1 libpq待機を FD イベント待機へ変更

### 変更対象

- `allographer/query_builder/libs/postgres/postgres_impl.nim`
- `allographer/query_builder/libs/postgres/postgres_rdb.nim`（既存宣言活用）

### 追加する内部ヘルパ

- `waitPgReadable(db: PPGconn, timeoutMs: int): Future[bool]`
- `waitPgWritable(db: PPGconn, timeoutMs: int): Future[bool]`
- `cancelQuery(db: PPGconn)`

#### waitPgReadable / waitPgWritable の要点

1. `fd = pqsocket(db)` を取得
2. `AsyncFD(fd)` を dispatcher に `register`（未登録時のみ）
3. `addRead` / `addWrite` で Future 完了
4. `withTimeout` で期限管理
5. 完了/タイムアウト時に `unregister` してリーク回避

### クエリ実行アルゴリズム（共通化）

`postgres_impl.nim` に共通ループを導入する。

- `send` フェーズ
  - `pqsendQueryParams(...)` 実行
  - `pqflush` が `1` の間は `waitPgWritable` で待機
- `receive` フェーズ
  - `pqconsumeInput`
  - `pqisBusy == 1` なら `waitPgReadable` で待機
  - ready 後に `pqgetResult` を drain

タイムアウト時は `cancelQuery` 実行。

#### cancelQuery の改善点

- `pqGetCancel` -> `pqCancel` -> `pqFreeCancel` を必ず実施
- `errbufsize` は `0` ではなく `ERROR_MSG_LENGTH` を使う

## 5.2 dbOpen 時に non-blocking を保証

### 変更対象

- `allographer/query_builder/models/postgres/postgres_open.nim`

### 仕様

`dbOpen` で生成した各 `PPGconn` に対して以下を実施:

1. `pqsetnonblocking(conn, 1)`
2. 失敗時は `DbError`
3. `pqisnonblocking(conn) == 1` を確認（失敗時は例外）

これにより `PQsendQuery* / PQconsumeInput / PQisBusy` 前提が明確になる。

## 5.3 接続プール空き待ちを通知ベースに変更

### 変更対象

- `allographer/query_builder/models/postgres/postgres_types.nim`
- `allographer/query_builder/models/postgres/postgres_exec.nim`

### データ構造追加

`Connections` に待機キューを追加:

- `waiters*: Deque[Future[void]]`

### getFreeConn の新仕様

1. まず空きスキャン
2. 空きなしなら waiter Future をキューへ登録
3. `withTimeout` で待機
4. 起床後に再スキャン
5. timeout なら `errorConnectionNum` を返す

### returnConn の新仕様

1. `isBusy = false`
2. `waiters` から未完了 waiter を 1 つ完了
3. 余剰/完了済み waiter は破棄

### 補足

初回は `threads:off` 前提で設計する。`threads:on` 運用を保証する場合は `Connections` への lock 導入を別タスクで追加する。

## 6. 互換性

- 公開 API シグネチャ変更なし。
- 呼び出し側 (`basolato`) の変更不要。
- 挙動上の差分は「高負荷時の待機遅延縮小」のみを狙う。

## 7. 失敗時挙動

1. `pqsocket < 0`: `DbError` で失敗。
2. タイムアウト: `cancelQuery` 実行後に `DbError`。
3. `cancelQuery` 自体が失敗した場合: エラー文言を付加して例外。
4. dispatcher 登録/解除エラー: 例外化し上位へ伝播。

## 8. テスト設計

## 8.1 単体テスト（allographer側）

1. `waitPgReadable` が read event で復帰する。
2. `waitPgReadable` timeout が正しく `false` を返す。
3. `cancelQuery` が `pqFreeCancel` を呼ぶ。
4. `getFreeConn` が通知で復帰する（`sleepAsync` 非依存）。

## 8.2 結合テスト

1. `httpbeast/httpx` + Postgres で `/db` レイテンシ回帰確認。
2. `asynchttpserver` と比較して極端な乖離（>1.5x）がないこと。
3. プール枯渇時（`DB_MAX_CONNECTION=1`, 高並列）でもタイムアウトまでの待機が滑らか。

## 8.3 回帰テスト

1. 既存 CRUD クエリの結果互換。
2. transaction 系 API の動作。
3. 例外時メッセージの互換（最低限意味が保たれること）。

## 9. 実装ステップ

1. `postgres_impl.nim` に FD 待機ヘルパを追加。
2. query/exec/rawQuery/rawExec の `sleepAsync` ループを置換。
3. `postgres_open.nim` で `pqsetnonblocking` を強制。
4. `postgres_types.nim` に `waiters` を追加。
5. `postgres_exec.nim` の `getFreeConn/returnConn` を通知ベースへ置換。
6. 単体/結合テスト追加。
7. ベンチ比較し、閾値を満たすことを確認。

## 10. 受け入れ基準

1. PostgreSQLクエリ待機ループから `await sleepAsync(10)` が排除されている。
2. `httpbeast/httpx` での単純待機 API の遅延増幅が DBクエリでも再現しない。
3. プール空き待機で `sleepAsync` ポーリングを使わない。
4. 既存の公開 API 変更なしで全テストが通る。

## 11. ロールアウト計画

1. `allographer` を fork し feature branch で実装。
2. basolato 側は fork 版依存で検証。
3. 問題なければ upstream PR。
4. upstream 取り込み後に basolato の依存を正式版へ戻す。

