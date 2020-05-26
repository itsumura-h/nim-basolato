# 必ずセッション作る
## before
- なにもしない

## newController
- セッションIDある
  - 接続
- セッションIDない
  - 新

## after
- なにもしない


# セッションはログイン後のみ
## before
- セッションIDある
  - なにもしない
- セッションIDない
  - raise エラー
## newController
- セッションIDある
  - 接続

## after
- なにもしない