RealWorld app architecture
==========================

このディレクトリの `app` は、`.cursor/rules/project.mdc` に従った構成になっています。

## app.bk について

- `examples/realworld/app.bk` は**過去実装のバックアップ用フォルダ**です。**触らないでください。**
- 実装・修正はすべて **`examples/realworld/app`** にのみ行います。`app.bk` を参照するだけにし、編集やコピー先にしないでください。

## View レイヤの基本パターン

- **Page → Template → Component** の順で依存します。Presenter は使いません。
- **Template の引数は `Context` のみ**です。Template は内部で `XxxTemplateModel.new(context)` を呼び、template model が context と必要な DAO から自己を組み立てます。
- Template / Component は `context()` や `signal` などの共有状態に依存せず、Template は受け取った context から model を構築し、Component は model の一部（ComponentModel）だけを受け取って描画します。

### Page

- `proc XxxPageView*(context: Context): Future[Component]` という形で定義します。
- `template(context).await` で body を取得し、`appLayout(context, title, body).await` で Layout と合成した `Component` を返します。Presenter は呼びません。

### Template

- **`proc xxxTemplate*(context: Context): Future[Component]`** という形で定義します。引数は context のみです。
- 内部で `let model = await XxxTemplateModel.new(context)` を実行し、template model が context と DAO から自己を組み立てたうえで、その model を使って HTML を描画します。
- データ取得の単位は Template です。必要な DAO の呼び出しと DTO→model の変換は、すべて対応する template model のコンストラクタに集約します。

### Template Model

- `proc new*(_: type XxxTemplateModel, context: Context): Future[XxxTemplateModel]` で、context と必要な DAO を使って自身（および配下の component model）を組み立てます。
- CSRF トークン、認証状態、flash、params などは context からここで解決し、model のフィールドとして Template に渡します。Template / Component は `Context` を直接参照しません。

### Component

- Component は ComponentModel だけを受け取り、DB アクセスや `Context` 取得は行いません。Template の template model が持つ component model を渡して描画します。

## Read/Write 分離

- **write-side**
  - `usecases/**`, `models/aggregates/**`, `models/vo/**`, `data_stores/repositories/**` を中心に構成します。
  - Controller から Usecase を呼び出し、Aggregate と Repository を通じて更新処理を行います。
- **read-side**
  - `models/dto/**`, `data_stores/dao/**`, `http/views/templates/**`, `http/views/components/**` を中心に構成します。
  - DAO は Template 単位で DTO を取得し、**template model が DAO を呼び出して DTO を受け取り、自身を組み立てます**。Presenter は存在しません。

## Context と CSRF の扱い

- `Context` は Controller から Page へ引数で渡し、Page から Template へも context のみを渡します。
- CSRF トークンなど request-local な値は、**template model のコンストラクタ内で** `context.csrfToken().toString()` などを使って解決し、model のフィールドに持たせます。Template は model 経由でのみそれらを参照します。
