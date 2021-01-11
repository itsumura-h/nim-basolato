エラー
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [Error](#error)
      * [Introduction](#introduction)
      * [Raise Error and Redirect](#raise-error-and-redirect)
      * [How to display custom error page](#how-to-display-custom-error-page)

<!-- Added by: root, at: Sun Dec 27 18:22:07 UTC 2020 -->

<!--te-->

## イントロダクション
例外が発生した時、Basolatoフレームワークはそれをキャッチし、例外型が持つステータスのレスポンスをクライアントへ返します。

```nim
raise newException(Error403, "session timeout")
```
この場合は`403`ステータスコードで、「session timeout」がボディに入っているレスポンスを返します。

Basolatoは`300`から`505`までの全てのレスポンスステータスの例外型を持っています。

[HTTPステータスコード一覧](https://ja.wikipedia.org/wiki/HTTPステータスコード)


## 例外発生させながらリダイレクトさせたい時
もし例外が発生した時に同時にリダイレクトさせたい時は、`errorRedirect`関数を使ってください。
この関数はコントローラーの中でのみ使えます。

```nim
return errorRedirect("/login")
```

コントローラー以外では、`ErrorRedirect`エラーを発生させてください。
```nim
raise newException(ErrorRedirect, "/login")
```

## 独自のエラーページを表示するには
Basolatoは専用のエラーページを持っています。しかし`./resources/errors/{http code}.html`の形式に沿ってファイルを作ることで、独自のエラーページを表示させることもできます。  
もしHTTPステータスコードと一致するHTMLファイルが存在せず、かつ`error.html`が存在する場合は、`error.html`が表示されます。

・優先順位  
{http code}.html > error.html > Basolato独自のエラーページ

この機能は本番環境（コンパイルオプションに`-d:release`を付けた時）のみ有効になります。  
開発環境では常にフレームワーク独自のエラーページが表示されます。

```
└── resources
    └── errors
        ├── 404.html # ユーザーオリジナルエラーページ
        ├── 500.html # ユーザーオリジナルエラーページ
        └── error.html # ユーザーオリジナルエラーページ
```
