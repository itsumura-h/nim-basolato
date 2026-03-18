# Basolato View 設計ガイド

この文書は、Basolato における参照系(GET)の使い方と設計方針を、リクエスト処理の流れに沿ってまとめたものです。`main.nim` から始まる実行順に合わせて、`Route.get`、`controller`、`pageView`、`templateModel`、`di container`、`DAO`、`DTO`、`template`、`component`、`appLayoutModel`、`appLayout` の順で説明します。

## 1. 全体像

Basolato の GET 参照系は、次の流れで組み立てます。

```text
Route.get
  -> controller
  -> pageView(context)
  -> templateModel.new(context)
  -> di container
  -> DAO
  -> DTO
  -> template / component
  -> appLayoutModel.new(context, title, body)
  -> appLayout(layoutModel)
  -> render(response)
```

この流れの目的は、HTTP の入口、画面構成、データ取得、描画を明確に分離することです。

## 2. Route.get

参照系処理の起点は `Route.get(...)` です。GET リクエストは router から controller へ渡されます。

```nim
Route.get("/some-page", some_controller.somePage)
```

ここでの役割は単純です。

- URL と controller を結び付ける
- middleware を差し込む
- GET の画面表示処理の入口を定義する

`Route.get` 自体は画面構築を行いません。画面の責務は常に controller 以降へ渡します。

## 3. Controller

controller は HTTP 境界です。Basolato の参照系では、controller は薄く保つのが基本です。

### 3.1 命名

参照系 controller の命名は次を基本にします。

- 画面表示: `*Page`
- 詳細表示: `show`
- 一覧表示: `index`

例:

- `signInPage`
- `signUpPage`
- `settingPage`
- `show`
- `index`

### 3.2 責務

controller の責務は次の範囲に限定します。

- `Context` を受け取る
- 対応する pageView を呼ぶ
- `render(...)` で `Response` を返す
- 必要なら認証・認可・リダイレクト判断を行う

標準形は次の通りです。

```nim
proc somePage*(context: Context): Future[Response] {.async.} =
  let page = somePageView(context).await
  return render(page)
```

controller が持つべきでない責務は次の通りです。

- HTML の組み立て
- DAO 呼び出しの詳細
- template ごとの描画ロジック
- component 単位のデータ整形

## 4. PageView

controller の次に呼ばれるのが pageView です。pageView はフルページの composition 層です。

### 4.1 命名

フル HTML を組み立てる View 入口は `*PageView` を推奨します。

例:

- `loginPageView`
- `homePageView`
- `articlePageView`

`*Page` と `*PageView` を分けることで、HTTP の入口と View の入口を区別できます。

### 4.2 責務

pageView の責務は次の通りです。

- request-local な `Context` を受け取る
- どの template を使うか決める
- 必要に応じて複数 template を合成する
- body を作る
- 最後に layout を適用する

標準形は次の通りです。

```nim
proc somePageView*(context: Context): Future[Component] {.async.} =
  let model = SomeTemplateModel.new(context).await
  let body = someTemplate(model)
  let layoutModel = AppLayoutModel.new(context, "Page Title", body).await
  return appLayout(layoutModel)
```

pageView が持つべきでない責務は次の通りです。

- DAO 実装の詳細
- template 内部の細かな描画
- component 内部のロジック

### 4.3 単一 template ページと複数 template ページ

単一 template ページ:

```text
pageView(context)
  -> TemplateModel.new(context)
  -> template(model)
  -> AppLayoutModel.new(...)
  -> appLayout(...)
```

複数 template ページ:

```text
pageView(context)
  -> MainSectionTemplateModel.new(context)
  -> mainSectionTemplate(model)
  -> SidebarTemplateModel.new(context)
  -> sidebarTemplate(model)
  -> pageBody(mainSection, sidebar)
  -> AppLayoutModel.new(...)
  -> appLayout(...)
```

## 5. TemplateModel

pageView の次で中心になるのが template model です。template model は参照系 read-side の組み立て責務を持ちます。

### 5.1 命名

template に対応する表示用データは `*TemplateModel` とします。

例:

- `LoginTemplateModel`
- `FeedTemplateModel`
- `PopularTagsTemplateModel`

template model は template と 1 対 1 を基本にします。

### 5.2 責務

template model の責務は次の通りです。

- `Context` から request-local な値を取得する
- `di container` を通じて必要な DAO を使う
- DAO から返る DTO を受け取る
- DTO を描画用データへ変換する
- component 用 model を組み立てる
- template がそのまま描画できる形へ整える

template model に集約すべき値の例:

- 認証状態
- CSRF トークン
- old input
- validation error
- flash message
- pagination 情報
- template 配下で使う一覧データ

template model は request-local な値と DB 取得値の合流地点です。

## 6. DI Container

template model の内部で依存解決に使うのが `di container` です。

### 6.1 役割

`di container` の役割は次の通りです。

- DAO の実装を集約して公開する
- template model が具体実装を直接 new しないようにする
- 実 DB とテストダブルの差し替えを容易にする

template model は `di container` を通じて必要な DAO へアクセスします。

```nim
proc new*(_: type SomeTemplateModel, context: Context): Future[SomeTemplateModel] {.async.} =
  let dtoList = di.someDao.fetchList().await
  return SomeTemplateModel.new(dtoList)
```

### 6.2 原則

- `di container` に触れてよい主な場所は template model
- controller から DAO を直接解決しない
- template や component から `di` を直接使わない

## 7. DAO

`di container` の先にあるのが DAO です。

DAO は `Data Access Object` の略です。

### 7.1 役割

DAO は参照専用のデータ取得境界です。Basolato では read-side 専用として扱います。

DAO の主な責務は次の通りです。

- DB から必要なデータを取得する
- join、batch、aggregation を行う
- 参照用途に適した DTO を返す
- N+1 を避けるために template 単位でまとめて取得する

### 7.2 設計方針

- DAO は table 単位ではなく template 単位で設計する
- component 単位で DAO を分けすぎない
- template 内 loop ごとの取得を避ける

たとえば一覧画面では、template model が一覧用 DAO を 1 回呼び、必要な件数をまとめて受け取る設計を推奨します。

```text
TemplateModel
  -> ArticleListDao
  -> seq[ArticleListDto]
  -> seq[FeedArticleComponentModel]
  -> template / component
```

### 7.3 DAO が持つべきでない責務

- HTML 用の文字列整形
- component の描画都合そのもの
- domain の更新ロジック
- HTTP request 依存

## 8. DTO

DAO が返すのが DTO です。

DTO は `Data Transfer Object` の略です。

### 8.1 役割

DTO は DAO が取得した結果を template model へ渡すための運搬オブジェクトです。

DTO の主な役割は次の通りです。

- DB 行や join 結果を扱いやすい形で表現する
- DAO と template model の橋渡しをする
- domain model と View 用 model を直接結合させない

### 8.2 設計方針

- primitive 中心で構成する
- 参照用途に必要な値だけを持つ
- 振る舞いは極力持たせない
- HTML 描画都合は持ち込まない

DTO は画面描画の最終形ではありません。最終形は template model や component model が担当します。

役割分担は次の通りです。

- DTO: 取得結果の運搬
- TemplateModel: DTO を描画向けへ再構成
- Template: 再構成済み model を描画

## 9. Template

template model で準備した表示用データを受けて、HTML を描画するのが template です。

### 9.1 命名

HTML 断片を描画する関数は `*Template` とします。

例:

- `loginTemplate`
- `feedTemplate`
- `popularTagsTemplate`

### 9.2 責務

template の責務は次の通りです。

- model の値を出力する
- 条件分岐を行う
- 繰り返し描画を行う
- component を呼び出す

理想形は次の通りです。

```nim
proc someTemplate*(model: SomeTemplateModel): Component =
  tmpl"""
    <section>
      <h1>$(model.title)</h1>
    </section>
  """
```

### 9.3 template が持ち込むべきでない責務

- `Context` への直接依存
- DAO 呼び出し
- request ごとの状態解決
- domain ロジック

template は model を受けて描くだけ、という状態を目指します。

## 10. Component

template の中で再利用される小さな pure UI が component です。

### 10.1 命名

- component の入力: `*ComponentModel`
- component の描画関数: `*Component`

### 10.2 責務

- component は描画に専念する
- component の入力は template model 側で完成させる
- component から DAO を呼ばない
- component から `Context` を読まない

依存方向は次の形を推奨します。

```text
page
  -> template model
  -> component model
  -> template
  -> component
```

## 11. AppLayoutModel

template または page で body を作ったあと、共通レイアウト用データを組み立てるのが `AppLayoutModel` です。

### 11.1 命名

- `AppLayoutModel`
- `HeadLayoutModel`
- `NavbarLayoutModel`

### 11.2 責務

`AppLayoutModel` はレイアウト描画に必要な共通情報をまとめます。

- title
- head 用 model
- navbar 用 model
- body
- 必要なら footer や meta 情報

つまり page は body を作り、layout model は全体の共通部品をまとめます。

## 12. AppLayout

`AppLayoutModel` を受け取って HTML 文書全体を描画するのが `appLayout` です。

### 12.1 命名

- `appLayout`
- `headLayout`
- `navbarLayout`

### 12.2 責務

`appLayout` は HTML 文書全体を生成します。

- `<!DOCTYPE html>`
- `<html>`
- `<head>`
- 共通ナビゲーション
- body
- footer

これにより、page は「body の組み立て」、layout は「全体の殻の組み立て」と分離されます。

## 13. render

最後に controller が `render(page)` を呼び、`Component` を `Response` に変換します。

```nim
proc somePage*(context: Context): Future[Response] {.async.} =
  let page = somePageView(context).await
  return render(page)
```

`render` は HTTP 応答として返す最終段であり、View 構築の責務はここより前で完了しているべきです。

## 14. 命名規約のまとめ

Basolato の参照系では、役割ごとに次の命名を揃えることを推奨します。

- controller: `*Page`, `show`, `index`
- page: `*PageView`
- template model: `*TemplateModel`
- template: `*Template`
- component model: `*ComponentModel`
- component: `*Component`
- layout model: `*LayoutModel`
- layout: `*Layout`

Basolato では、`XxxModel + xxx関数` の組を View の基本単位として扱います。

## 15. 避けたいパターン

Basolato の参照系では、次のような書き方は避けるのが望ましいです。

- controller で HTML を直接組み立てる
- controller が `di.someDao` を直接呼ぶ
- template が `Context` を直接読む
- template や component から DAO を呼ぶ
- template 内の loop ごとに DAO を呼ぶ
- component 単位でデータ取得する
- DTO をそのまま template の public API にする
- request ごとの状態をグローバルに読む

これらは責務を曖昧にし、並行リクエスト安全性や保守性を落とします。

## 16. 設計原則の要約

Basolato の GET 参照系は、次の原則で設計します。

- `Route.get` は入口を定義するだけに留める
- controller は薄く保つ
- pageView はフルページの composition を担当する
- template model は read-side の取得と整形を担当する
- di container は依存解決の入口に限定する
- DAO は参照専用の取得境界として設計する
- DTO は取得結果の運搬に限定する
- template は純粋描画に寄せる
- component は pure UI に限定する
- appLayoutModel と appLayout は共通外枠を担当する
- `Context` は request-local に明示的に渡す

ひとことで言えば、Basolato の参照系設計は `Route.get -> controller -> pageView -> templateModel -> di container -> DAO -> DTO -> template/component -> appLayoutModel -> appLayout -> render` という責務分離を基本線にする、ということです。
