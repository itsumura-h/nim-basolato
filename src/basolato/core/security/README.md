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


セッションIDには以下の状態がある
- 正常
  - DBから取り出してインスタンスを返す
- 空文字
  - 新規作成してインスタンスを返す
- 不正な値
  - エラーを返す
