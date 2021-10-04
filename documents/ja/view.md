ビュー
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [ビュー](#ビュー)
      * [イントロダクション](#イントロダクション)
      * [XSS](#xss)
         * [API](#api)
         * [サンプル](#サンプル)
      * [コンポーネントスタイルデザイン](#コンポーネントスタイルデザイン)
         * [SCSS](#scss)
         * [API](#api-1)
      * [ヘルパー関数](#ヘルパー関数)
         * [Csrfトークン](#csrfトークン)
         * [old関数](#old関数)
      * [その他のテンプレートライブラリ](#その他のテンプレートライブラリ)
         * [ブロックコンポーネントの例](#ブロックコンポーネントの例)
            * [htmlgen](#htmlgen)
            * [SCF](#scf)
            * [Karax](#karax)

<!-- Added by: root, at: Sat Sep 18 06:56:40 UTC 2021 -->

<!--te-->

## イントロダクション
Basolatoでは、デフォルトのテンプレートエンジンとして、`nim-templates`を使用しています。これは `basolato/view` をインポートすることで利用できます。

```nim
import basolato/view

proc baseImpl(content:string): string =
  tmpli html"""
    <html>
      <heade>
        <title>Basolato</title>
      </head>
      <body>
        $(content.get)
      </body>
    </html>
  """

proc indexImpl(message:string): string =
  tmpli html"""
    <p>$(message.get)</p>
  """

proc indexView*(message:string): string =
  baseImpl(indexImpl(message))
```

## XSS
XSSを防止するために、 **変数に対して`get`関数を使用してください。** 内部で[xmlEncode](https://nim-lang.org/docs/cgi.html#xmlEncode,string)が適用されます。

### API
```nim
proc get*(val:JsonNode):string =

proc get*(val:string):string =
```

### サンプル
```nim
title = "This is title<script>alert("aaa")</script>"
params = @["<script>alert("aaa")</script>", "b"].parseJson()
```
```nim
import basolato/view

proc impl(title:string, params:JsonNode):Future[string] {.async.} =
  tmpli html"""
    <h1>$(title.get)</h1>
    <ul>
      $for param in params {
        <li>$(param.get)</li>
      }
    </ul>
  """
```

## コンポーネント指向
Basolato viewは、ReactやVueのようなコンポーネント指向のデザインを採用しています。 
コンポーネントとは、htmlとJavaScriptとCSSの単一の塊であり、htmlの文字列を返す関数のことです。

### JavaScript
controller
```nim
import basolato/controller

proc withSscriptPage*(request:Request, params:Params):Future[Response] {.async.} =
  return render(withScriptView())
```

view
```nim
import basolato/view
import ../layouts/application_view


proc impl():string =
  script ["toggle"], script:"""
    <script>
      window.addEventListener('load', ()=>{
        let el = document.getElementById('toggle')
        el.style.display = 'none'
      })

      const toggleOpen = () =>{
        let el = document.getElementById('toggle')
        if(el.style.display == 'none'){
          el.style.display = ''
        }else{
          el.style.display = 'none'
        }
      }
    </script>
  """

  tmpli html"""
    $(script)
    <div>
      <button onclick="toggleOpen()">toggle</button>
      <div id="$(script.element("toggle"))">...content</div>
    </div>
  """

proc withScriptView*():string =
  let title = "Title"
  return applicationView(title, impl())
```

これをhtmlにコンパイルすると以下のようになります。
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Title</title>
  </head>
  <body>
    <script>
      window.addEventListener('load', ()=>{
        let el = document.getElementById('toggle_akvcgccoeg')
        el.style.display = 'none'
      })

      const toggleOpen = () =>{
        let el = document.getElementById('toggle_akvcgccoeg')
        if(el.style.display == 'none'){
          el.style.display = ''
        }else{
          el.style.display = 'none'
        }
      }
    </script>
    <div>
      <button onclick="toggleOpen()">toggle</button>
      <div id="toggle_akvcgccoeg">...content</div>
    </div>
  </body>
</html>
```

`script`テンプレートの第一引数に渡されたセレクタはコンポーネントごとにランダムなサフィックスを持つので、複数のコンポーネントが同じID名/クラス名を持つことができます。

### CSS
controller
```nim
import basolato/controller

proc withStylePage*(request:Request, params:Params):Future[Response] {.async.} =
  return render(withStyleView())
```

view
```nim
import basolato/view
import ../layouts/application_view


proc impl():string =
  style "css", style:"""
    <style>
      .background {
        height: 200px;
        width: 200px;
        background-color: blue;
      }

      .background:hover {
        background-color: green;
      }
    </style>
  """

  tmpli html"""
    $(style)
    <div class="$(style.element("background"))"></div>
  """

proc withStyleView*():string =
  let title = "Title"
  return applicationView(title, impl())
```

これをhtmlにコンパイルすると以下のようになります。
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Title</title>
  </head>
  <body>
    <style type="text/css">
      .background_jtshlgnucx {
        height: 200px;
        width: 200px;
        background-color: blue;
      }
      .background_jtshlgnucx:hover {
        background-color: green;
      }
    </style>
    <div class="background_jtshlgnucx"></div>
  </body>
</html>
```

`style`テンプレートは、`CSS-in-JS`にインスパイアされた、コンポーネントごとのスタイルを作成するのに便利なタイプです。
スタイル化されたクラス名は、コンポーネントごとにランダムなサフィックスを持つので、複数のコンポーネントが同じクラス名を持つことができます。

### SCSS
また、[libsass](https://github.com/sass/libsass/)をインストールすれば、SCSSを使うことができます。

```sh
apt install libsass-dev
# or
apk add --no-cache libsass-dev
```

そして、次のようにスタイルブロックを書きます。
```nim
style "scss", style:"""
<style>
  .background {
    height: 200px;
    width: 200px;
    background-color: blue;

    &:hover {
      background-color: green;
    }
  }
</style>
"""
```

### API
`script` テンプレートは `Script` 型のインスタンスを `name` の 引数に格納します。
`style` テンプレートは `Css` 型のインスタンスを `name` の 引数に格納します。

```nim
# for JavaScript
template script*(selectors:openArray[string], name, body:untyped):untyped

template script*(name, body:untyped):untyped

proc `$`*(self:Script):string

proc element*(self:Script, name:string):string

# for CSS
template style*(typ:string, name, body: untyped):untyped

proc `$`*(self:Css):string

proc element*(self:Css, name:string):string
```

## ヘルパー関数

### Csrfトークン
`form`からPOSTリクエストを送信するには、`csrf token`を設定する必要があります。basolato/view` のヘルパー関数を利用することができます。

```nim
import basolato/view

proc index*():string =
  tmpli html"""
    <form>
      $(csrfToken())
      <input type="text", name="name">
    </form>
  """
```

### old関数
ユーザーの入力値が不正で、入力ページに戻して以前に入力された値を表示したい場合には、`old`ヘルパー関数を使います。

API
```nim
proc old*(params:JsonNode, key:string):string =

proc old*(params:TableRef, key:string):string =

```

controller
```nim
# getアクセス
proc signinPage*(request:Request, params:Params):Future[Response] {.async.} =
  return render(signinView())

# postアクセス
proc signin*(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  try
    ...
  except:
    return render(Http422, signinView(%params))
```

view
```nim
proc impl(params=newJObject()):string =
  tmpli html"""
    <input type="text" name="email" value="$(old(params, "email"))">
    <input type="text" name="password">
  """

proc signinView*(params=newJObject()):string =
  let title = "SignIn"
  return self.applicationView(title, impl(params))
```
`params` にキー `email` があれば値を表示し、なければ空の文字列を表示します。

## その他のテンプレートライブラリ
HTMLを生成する他のライブラリもBasolatoに選択することができます。しかし、それぞれのライブラリには、それぞれの利点と欠点があります。 

- [htmlgen](https://nim-lang.org/docs/htmlgen.html)
- [SCF](https://nim-lang.org/docs/filters.html)
- [Karax](https://github.com/pragmagic/karax)
- [nim-templates](https://github.com/onionhammer/nim-templates)

<table>
  <tr>
    <th>ライブラリ</th><th>メリット</th><th>デメリット</th>
  </tr>
  <tr>
    <td>htmlgen</td>
    <td>
      <ul>
        <li>Nim標準ライブラリ</li>
        <li>Nimプログラマなら簡単に使える</li>
        <li>1つのファイルに複数の関数を定義できる</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>if文やfor文が使えない</li>
        <li>デザイナーやマークアップエンジニアとの共同作業は難しいかもしれない</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>SCF</td>
    <td>
      <li>Nim標準ライブラリ</li>
      <li>if文、for文が使える</li>
      <li>デザイナーやマークアップエンジニアとの共同作業が容易</li>
    </td>
    <td>
      <ul>
        <li>1つのファイルに複数の関数を定義できない</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>Karax</td>
    <td>
      <li>1つのファイルに複数の関数を定義できる</li>
      <li>if文、for文が使える</li>
    </td>
    <td>
      <ul>
        <li>デザイナーやマークアップエンジニアとの共同作業は難しいかもしれない</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>nim-templates</td>
    <td>
      <ul>
        <li>1つのファイルに複数の関数を定義できる</li>
        <li>if文、for文が使える</li>
        <li>デザイナーやマークアップエンジニアとの共同作業が容易</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>個人がメンテナンスしている</li>
      </ul>
    </td>
  </tr>
</table>

ビューファイルは、`app/http/views`ディレクトリにある必要があります。

### ブロックコンポーネントの例

コントローラと出力結果はそれぞれの例で同じです。

controller
```nim
proc index*(): Response =
  let message = "Basolato"
  return render(indexView(message))
```

出力結果
```html
<html>
  <head>
    <title>Basolato</title>
  </head>
  <body>
    <p>Basolato</p>
  </body>
</html>
```

#### htmlgen

```nim
import htmlgen

proc baseImpl(content:string): string =
  html(
    head(
      title("Basolato")
    ),
    body(content)
  )

proc indexImpl(message:string): string =
  p(message)

proc indexView*(message:string): string =
  baseImpl(indexImpl(message))
```

#### SCF
SCFでは関数毎にファイルを分ける必要があります。

baseImpl.nim
```nim
#? stdtmpl | standard
#proc baseImpl*(content:string): string =
<html>
  <heade>
    <title>Basolato</title>
  </head>
  <body>
    $content
  </body>
</html>
```

indexImpl.nim
```nim
#? stdtmpl | standard
#proc indexImpl*(message:string): string =
<p>$message</p>
```

index_view.nim
```nim
#? stdtmpl | standard
#import baseImpl
#import indexImpl
#proc indexView*(message:string): string =
${baseImpl(indexImpl(message))}
```

#### Karax
**Server Side HTML Rendering** の使い方をしています。

```nim
import karax / [karasdsl, vdom]

proc baseImpl(content:string): string =
  var vnode = buildView(html):
    head:
      title: text("Basolato")
    body: text(content)
  return $vnode

proc indexImpl(message:string): string =
  var vnode = buildView(p):
    text(message)
  return $vnode

proc indexView*(message:string): string =
  baseImpl(indexImpl(message))
```
