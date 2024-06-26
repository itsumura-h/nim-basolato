ログ
===
[戻る](../../README.md)

目次
<!--ts-->
* [ログ](#ログ)
   * [イントロダクション](#イントロダクション)
   * [API](#api)
   * [サンプル](#サンプル)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 11:26:27 UTC 2024 -->

<!--te-->

## イントロダクション
環境変数`LOG_IS_DISPLAY`に`true`が設定されていれば、`echoLog`関数、`echoErrorMsg`関数を実行した時に、その内容がターミナルに表示されます。`false`が設定されていれば、表示されません。

環境変数`LOG_DIR`はログファイルを出力するディレクトリのパスです。

環境変数`LOG_IS_FILE`に`true`が設定されていれば、`echoLog`関数を実行した時に、その内容がログファイルに出力されます。`false`が設定されていれば、出力されません。

環境変数`LOG_IS_ERROR_FILE`に`true`が設定されていれば、`echoErrorMsg`関数を実行した時に、その内容がエラーログファイルに出力されます。`false`が設定されていれば、出力されません。

## API
```nim
proc echoLog*(output: any, args:varargs[string]) =

proc echoErrorMsg*(msg:string) =
```

## サンプル

```nim
import basolato/logging

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  echoLog("index")
```
