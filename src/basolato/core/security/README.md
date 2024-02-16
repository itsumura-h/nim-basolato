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

## CSRF Token
### MPA
##### 生成ミドルウェア
- トークン生成
- セッションを発行する
- トークンをセッションDBに保存
- globalCsrfTokenに代入
- cookieにセッションIDを入れてコントローラーへ送る
- viewに値をセットしてクライアントへ返す

#### チェックミドルウェア
##### session from cookie
- cookieからセッションIDを取り出す
- セッションのインスタンスをcontextに作る
  - 値が不正ならセッションを新規作成
- セッションからnonceを取り出してglobalCsrfTokenに代入

##### check csrf token
- リクエストパラメータのcsrf-tokenから値を取り出す
- contextのセッションからnonceを取り出す
- 一致するか確認


### API
#### 生成ミドルウェア
- X-SESSION-ID
- X-CSRF-TOKEN
の2つを作る

#### チェックミドルウェア
##### session from header
- リクエストヘッダーのX-SESSION-IDからセッションIDを取り出す
- セッションのインスタンスをcontextに作る
- セッションからnonceを取り出してglobalCsrfTokenに代入

##### check csrf token api
- リクエストヘッダーのX-CSRF-TOKENから値を取り出す
- contextのセッションからnonceを取り出す
- 一致するか確認
