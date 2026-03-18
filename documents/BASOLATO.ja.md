# Basolato 設計ガイド

この文書は、Basolato における参照系(GET)と更新系(POST)の使い方と設計方針を、リクエスト処理の流れに沿ってまとめたものです。全体を「参照系」と「更新系」の2大カテゴリに分け、`main.nim` から始まる実行順に沿って整理しています。

## 1. 参照系

### 1.1 全体像

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

### 1.2 Route.get

参照系処理の起点は `Route.get(...)` です。GET リクエストは router から controller へ渡されます。

```nim
Route.get("/some-page", some_controller.somePage)
```

ここでの役割は単純です。

- URL と controller を結び付ける
- middleware を差し込む
- GET の画面表示処理の入口を定義する

`Route.get` 自体は画面構築を行いません。画面の責務は常に controller 以降へ渡します。

### 1.3 Controller

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

### 1.4 PageView

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

### 1.5 TemplateModel

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

### 1.6 DI Container

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

### 1.7 DAO

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

### 1.8 DTO

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

### 1.9 Template

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

### 1.10 Component

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

### 1.11 AppLayoutModel

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

### 1.12 AppLayout

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

### 1.13 render

最後に controller が `render(page)` を呼び、`Component` を `Response` に変換します。

```nim
proc somePage*(context: Context): Future[Response] {.async.} =
  let page = somePageView(context).await
  return render(page)
```

`render` は HTTP 応答として返す最終段であり、View 構築の責務はここより前で完了しているべきです。

### 1.14 命名規約のまとめ

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

### 1.15 避けたいパターン

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

### 1.16 設計原則の要約

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

## 2. 更新系

### 2.1 全体像

Basolato の POST 更新系は、次の流れで組み立てます。

```text
Route.post
  -> controller
  -> validation
  -> usecase
  -> value object
  -> aggregate / entity
  -> domain service
  -> repository
  -> di container
  -> redirect / error handling
```

この流れの目的は、HTTP 入力、業務ルール、永続化を分離することです。controller で入力を受け、usecase が更新ユースケースを進め、aggregate 配下と repository がドメイン整合性と永続化を担います。

### 2.2 Route.post

更新系処理の起点は `Route.post(...)` です。POST リクエストは router から controller へ渡されます。

```nim
Route.post("/login", auth_controller.signIn)
Route.post("/register", auth_controller.signUp)
Route.post("/settings", setting_controller.updateSettings)
```

ここでの役割は次の通りです。

- URL と更新 controller を結び付ける
- middleware を差し込む
- POST の更新処理の入口を定義する

`Route.post` 自体は業務ロジックを持ちません。更新の実処理は controller 以降へ渡します。

### 2.3 Controller

POST の controller も HTTP 境界です。参照系と同じく薄く保ちます。

### 19.1 命名

更新系 controller の命名は、HTTP アクションに対応した動詞をそのまま使う形を基本にします。

例:

- `signIn`
- `signUp`
- `signOut`
- `updateSettings`
- `follow`

### 19.2 責務

更新系 controller の責務は次の通りです。

- `Context` から入力を受け取る
- request validation を行う
- バリデーションエラー時は flash や old input を保存して redirect する
- usecase を呼ぶ
- 成功時は session 更新や redirect を行う
- 例外時は error を保存して redirect する

`signIn` / `signUp` の標準形は次のように整理できます。

```nim
proc someAction*(context: Context): Future[Response] {.async.} =
  let validation = RequestValidation.new(context)
  # validate...

  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/some-form")

  let someValue = context.params.getStr("someValue")

  try:
    let usecase = SomeUsecase.new()
    let result = usecase.invoke(someValue).await
    # session / flash / redirect
    return redirect("/")
  except:
    let error = getCurrentExceptionMsg()
    context.storeError(error).await
    return redirect("/some-form")
```

controller が持つべきでない責務は次の通りです。

- VO や aggregate の内部ルール実装
- repository の SQL や DB 更新詳細
- domain service の判定ロジック
- 複数 repository をまたぐ業務フローの中心責務

### 2.4 Usecase

controller の次で更新フローの中心になるのが usecase です。

### 20.1 命名

更新系のアプリケーション層は `*Usecase` とします。

例:

- `LoginUsecase`
- `RegisterUsecase`
- `UpdateSettingUsecase`
- `FollowUsecase`

### 20.2 責務

usecase の責務は次の通りです。

- controller から受けた primitive な入力を業務フローへ乗せる
- string を VO に変換する
- repository や service を使って業務処理を進める
- aggregate / entity を生成または復元する
- 最終的に repository へ保存を依頼する
- controller に返す最小限の戻り値を組み立てる

`signUp` を基準にした更新フローは次のようになります。

```text
Route.post("/register")
  -> auth_controller.signUp(context)
  -> RegisterUsecase.new()
  -> RegisterUsecase.invoke(name, email, password)
  -> UserName.new / Email.new / Password.new
  -> repository.getUserByEmail(email)
  -> DraftUser.new(...)
  -> repository.create(draftUser)
  -> tuple[id, name]
  -> controller が session 更新 / redirect
```

`signIn` は作成ではなく認証寄りの更新系で、次のようになります。

```text
Route.post("/login")
  -> auth_controller.signIn(context)
  -> LoginUsecase.new()
  -> LoginUsecase.invoke(email, password)
  -> Email.new / Password.new
  -> repository.getUserByEmail(email)
  -> UserService.isMatchPassword(...)
  -> tuple[id, name]
  -> controller が session 更新 / redirect
```

### 20.3 Usecase が持つべきでない責務

- SQL の直接記述
- HTML や Response の構築
- `Context` への依存
- read-side DTO の組み立て

### 2.5 Aggregate / Entity

更新系の中心モデルは aggregate 配下に置きます。実装では entity を aggregate 配下へ置く形を基本にします。

### 21.1 命名

aggregate 配下の命名は次を基本にします。

- 集約ルートや entity: `User`, `DraftUser`, `Follow`
- 配置: `models/aggregates/<aggregate名>/...`

例:

- `models/aggregates/user/user_entity.nim`
- `models/aggregates/user/user_service.nim`
- `models/aggregates/user/user_repository_interface.nim`

### 21.2 Entity の役割

entity は更新対象のドメイン状態を表現します。

- `DraftUser`: 新規作成前提のユーザー
- `User`: 永続化済みユーザー

このように、作成前と作成後で型を分けるのは有効なパターンです。

たとえば `DraftUser.new(...)` の中で `UserId.new()` や `HashedPassword.new(password)` を行えば、作成時の整形責務を entity 側へ寄せられます。

### 21.3 設計方針

- 更新系のモデルは aggregate 配下へ置く
- repository が返すのは DTO ではなく aggregate / entity
- create 前後で状態が違うなら型を分ける
- VO を field として持たせる
- entity は domain 上意味のある単位で切る

### 2.6 Domain Service

aggregate 単体では表しづらい判定や、repository を使う判定は domain service に置きます。

### 22.1 命名

domain service の命名は `*Service` とします。

例:

- `UserService`

### 22.2 責務

domain service の責務は次の通りです。

- repository を使った存在確認や重複確認
- 値比較やハッシュ照合などの domain 判定
- aggregate に閉じにくい業務ルールの表現

`UserService` では次のような責務が典型です。

- `isEmailUnique(email)`
- `isExistsUser(userId)`
- `isMatchPassword(input, hashed)`

### 22.3 設計方針

- service は domain 判定に集中させる
- 更新結果の永続化そのものは repository に任せる
- HTTP や View の概念は持ち込まない

### 2.7 Value Object

usecase が string を受けたあと、更新系の早い段階で VO に変換します。

### 23.1 命名

VO は型名で業務意味を表すことを基本にします。

例:

- `UserId`
- `UserName`
- `Email`
- `Password`
- `HashedPassword`
- `Bio`
- `Image`

配置は `models/vo/...` を基本にします。

### 23.2 役割

VO の役割は次の通りです。

- primitive string を domain 上の意味ある型へ変換する
- 不正値チェックをコンストラクタへ寄せる
- 以降の層で「ただの string」を減らす

たとえば次のような責務が入ります。

- `UserName.new(value)`: 空文字禁止
- `UserId.new(value)`: 空 id 禁止
- `HashedPassword.new(password)`: ハッシュ化

### 23.3 設計方針

- usecase の入口でなるべく早く VO 化する
- repository や service の引数は primitive より VO を優先する
- VO の `new` に validation や正規化を寄せる
- domain error は VO 生成時点で失敗させてよい

### 2.8 Repository Interface

aggregate を永続化・復元する境界は repository です。

### 24.1 命名

repository interface の命名は `I<AggregateName>Repository` を基本にします。

例:

- `IUserRepository`

配置は aggregate 配下に置く形を推奨します。

- `models/aggregates/user/user_repository_interface.nim`

### 24.2 役割

repository interface の責務は次の通りです。

- aggregate / entity の取得 API を定義する
- create / update などの永続化 API を定義する
- usecase と具体実装を分離する

典型的な interface は次のようになります。

```text
getUserByEmail(email: Email): Future[Option[User]]
getUserById(userId: UserId): Future[Option[User]]
create(user: DraftUser): Future[void]
update(user: User): Future[void]
```

戻り値に DTO ではなく `User` や `DraftUser` を使う点が、read-side DAO との大きな違いです。

### 2.9 Repository 実装

repository interface を実装する具体クラスは、`data_stores/repositories/...` 配下へ置きます。

### 25.1 命名

- 本番実装: `<AggregateName>Repository`
- テスト実装: `Mock<AggregateName>Repository`

例:

- `UserRepository`
- `MockUserRepository`

### 25.2 責務

repository 実装の責務は次の通りです。

- DB 行から aggregate / entity を復元する
- aggregate / entity を DB へ保存する
- persistence 形式と domain 形式を相互変換する

典型的な流れは次の通りです。

```text
repository.getUserByEmail(email)
  -> DB row を取得
  -> UserId / UserName / Email / HashedPassword などへ戻す
  -> User aggregate を復元して返す
```

```text
repository.create(draftUser)
  -> draftUser の VO を primitive に展開
  -> insert
```

### 25.3 Repository が持つべきでない責務

- HTML 用整形
- request-local な `Context` 依存
- read-side template 用の DTO 組み立て

### 2.10 DI Container

更新系で usecase や service が依存する repository は `di container` から解決します。

### 26.1 命名

DI container 上の field 名は、interface の意味が伝わる lowerCamelCase を基本にします。

例:

- `userRepository*: IUserRepository`

### 26.2 役割

更新系の `di container` の責務は次の通りです。

- repository interface と具体実装を結び付ける
- test と production の実装を切り替える
- usecase / service が具体クラスへ直接依存しないようにする

`di_container.nim` では write-side と read-side をコメントで分け、write-side に repository、read-side に DAO を置く構成を推奨します。

### 26.3 原則

- usecase は `di.userRepository` のように interface 経由で依存する
- service も必要なら同じ repository interface に依存する
- controller から repository を直接引かない

### 2.11 推奨フロー

`signUp` を基準にした、Basolato の更新系の基準形は次の通りです。

```text
Route.post
  -> controller
  -> validation
  -> usecase
  -> UserName / Email / Password などの VO 生成
  -> repository / service による業務判定
  -> DraftUser / User などの aggregate entity 生成
  -> repository.create / update
  -> controller が session / flash / redirect を処理
```

コード形は次のようになります。

```nim
proc someAction*(context: Context): Future[Response] {.async.} =
  let validation = RequestValidation.new(context)
  # validate...

  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/form")

  let a = context.params.getStr("a")
  let b = context.params.getStr("b")

  try:
    let usecase = SomeUsecase.new()
    let result = usecase.invoke(a, b).await
    return redirect("/")
  except:
    let error = getCurrentExceptionMsg()
    context.storeError(error).await
    return redirect("/form")
```

```nim
proc invoke*(self: SomeUsecase, a, b: string) {.async.} =
  let a = SomeVo.new(a)
  let b = AnotherVo.new(b)
  let entity = SomeAggregate.new(a, b)
  self.repository.create(entity).await
```

### 2.12 避けたいパターン

Basolato の POST 更新系では、次のような書き方は避けるのが望ましいです。

- controller が repository を直接呼ぶ
- controller で VO 生成から永続化まで完結させる
- usecase が `Context` に依存する
- repository が DTO を返して更新系の中心になる
- read-side DAO を write-side 更新に流用する
- aggregate を使わず primitive だけで更新を進める
- domain 判定を controller や template model に置く

これらは更新系の責務境界を崩し、業務ルールの所在を曖昧にします。

### 2.13 設計原則の要約

Basolato の POST 更新系は、次の原則で設計します。

- `Route.post` は入口定義に留める
- controller は入力受付、validation、redirect に集中する
- usecase は更新ユースケースの進行役を担う
- aggregate 配下に entity、service、repository interface を置く
- value object で primitive を domain 型へ変換する
- repository は aggregate の復元と永続化を担う
- di container で repository 実装を差し替え可能にする
- read-side の DAO / DTO と write-side の repository / aggregate を混ぜない

ひとことで言えば、Basolato の更新系設計は `Route.post -> controller -> usecase -> value object -> aggregate/entity -> service -> repository -> di container -> redirect` という責務分離を基本線にする、ということです。
