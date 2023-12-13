dependency

context  
↓  
session / cookie  
↓  
session db interface
↓
Json session db / Redis session db
↓  
random_string  

セッションIDが不正な場合は再生成する
匿名ユーザーにセッションを作るかどうかは、どのエンドポイントにセッションを作るミドルウェアを割当るかで対応する

- idから空文字かどうか
  - 空文字ならid再生成
- idが有効かチェック
  - 有効でないならid再生成
- インスタンスを生成して返す


## CookieにセッションIDがある時

## CSRF Token

## AuthorizationヘッダーにセッションIDがある時
