ビュー
===
[戻る](../../README.md)

目次
<!--ts-->
- [ビュー](#ビュー)
  - [イントロダクション](#イントロダクション)
  - [文法](#文法)
    - [if](#if)
    - [for](#for)
    - [while](#while)
  - [コンポーネント指向](#コンポーネント指向)
    - [CSS](#css)
    - [SCSS](#scss)
    - [API](#api)
  - [ヘルパー関数](#ヘルパー関数)
    - [Csrfトークン](#csrfトークン)
    - [old関数](#old関数)
  - [SCFをテンプレートエンジンとして使う](#scfをテンプレートエンジンとして使う)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Fri Dec 22 21:22:56 UTC 2023 -->

<!--te-->

## イントロダクション
Basolatoでは、デフォルトのテンプレートエンジンとして、[nim-templates](https://github.com/onionhammer/nim-templates)をカスタマイズしたオリジナルのものを使用しています。これは `basolato/view` をインポートすることで利用できます。

```nim
import basolato/view

proc baseImpl(content:Component): Component =
  tmpli html"""
    <html>
      <heade>
        <title>Basolato</title>
      </head>
      <body>
        $(content)
      </body>
    </html>
  """

proc indexImpl(message:string): Component =
  tmpli html"""
    <p>$(message)</p>
  """

proc indexView*(message:string): string =
  $baseImpl(indexImpl(message))
```

## 文法
### if
```nim
proc indexView(arg:string):Component = tmpli html"""
$if arg == "a"{
  <p>A</p>
}
$elif arg == "b"{
  <p>B</p>
}
$else{
  <p>C</p>
}
"""
```

### for
```nim
proc indexView(args:openarray[string]):Component = tmpli html"""
<li>
  $for row in args{
    <ul>$(row)</ul>
  }
</li>
"""
```

### while
```nim
proc indexView(args:openarray[string]):Component = tmpli html"""
<ul>
  ${ var y = 0 }
  $while y < 4 {
    <li>$(y)</li>
    ${ inc(y) }
  }
</ul>
```

## コンポーネント指向
Basolato viewは、ReactやVueのようなコンポーネント指向のデザインを採用しています。 
コンポーネントとは、htmlとJavaScriptとCSSの単一の塊であり、htmlの文字列を返す関数のことです。  
Basolatoではコンポーネントの親子構造を実現するために、`Componnet`という型を用意しています。コンポーネントの返り値には `Component`を使ってください。


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


proc impl():Component =
  let style = styleTmpl(Css, """
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
  """)

  tmpli html"""
    $(style)
    <div class="$(style.element("background"))"></div>
  """

proc withStyleView*():Component =
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
let style = styleTmpl(Scss, """
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
`styleTmpl`関数は `Style` 型のインスタンスを作ります。

```nim
type StyleType* = enum
  Css, Scss

proc styleTmpl*(typ:StyleType, body:string):Style

proc element*(self:Style, name:string):string
```

## ヘルパー関数

### Csrfトークン
`form`からPOSTリクエストを送信するには、`csrf token`を設定する必要があります。basolato/view` のヘルパー関数を利用することができます。

```nim
import basolato/view

proc index*():Component =
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
proc old*(params:JsonNode, key:string, default=""):string
proc old*(params:TableRef, key:string, default=""):string
proc old*(params:Params, key:string, default=""):string
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
proc impl(params=newJObject()):Component =
  tmpli html"""
    <input type="text" name="email" value="$(old(params, "email"))">
    <input type="text" name="password">
  """

proc signinView*(params=newJObject()):Component =
  let title = "SignIn"
  return applicationView(title, impl(params))
```
`params` にキー `email` があれば値を表示し、なければ空の文字列を表示します。

## SCFをテンプレートエンジンとして使う
少し手を加えるだけで、テンプレートエンジンとして[SCF](https://nim-lang.org/docs/filters.html)を使うこともできます。

1. `#? stdtmpl | standard` を `#? stdtmpl(toString="toString") | standard`に差し替える
1. `basolato/view`をimportする
1. 返り値の型を`Component`にする
1. `result = ""` を `result = Component.new()`に差し替える
1. もし非同期で使いたい場合には、返り値の型を`Future[Componente]`にし、`{.async.}`プラグマを付けます

結果としてこのようにします。
```nim
#? stdtmpl(toString="toString") | standard
#import std/asyncdispatch
#import basolato/view
#proc indexView*(str:string, arr:openArray[string]): Future[Component] {.async.} =
# result = Component.new()
<!DOCTYPE html>
<html lang="en">
  <body>
    <p>${str}</p>
    <ul>
      #for row in arr:
        <li>${row}</li>
      #end for
    </ul>
  </body>
</html>
```

コントローラー
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let str = "<script>alert('aaa')</script>"
  let arr = ["aaa", "bbb", "ccc"]
  return render(indexView(str, arr).await)
```

ビューを作るコマンドに `--scf` を付けると、SCFでのビューファイルが作られます。
```sh
ducere make layout buttons/success_button --scf
ducere make page login --scf
```
