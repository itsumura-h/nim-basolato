# View テスト戦略（Presenter/ViewModel パターン）

## テスト対象

Presenter/ViewModel パターンで導入後、以下の観点でテストを実施する。

## 1. リクエスト隔離テスト

**目的**: 異なるリクエスト間で状態が混線しないことを保証

**テスト項目:**
- [ ] 複数の同時リクエストで、フォーム入力値が他のリクエストへ漏えいしない
- [ ] ログイン状態（isLogin フラグ）が別リクエストへ影響しない
- [ ] セッション名が複数リクエスト間で混線しない

**テスト例:**
```nim
suite "Request Isolation":
  test "Concurrent requests do not share form data":
    # リクエスト1: name="user1", password="pass1"
    # リクエスト2: name="user2", password="pass2"
    # → 各リクエストの ViewModel が独立していることを確認
```

**確認方法:**
- 手動テスト: 同時に複数ブラウザからログインリクエスト
- または、複数スレッド/タスク並列実行時のメモリダンプ確認

## 2. ViewModel 正確性テスト

**目的**: ViewModel が正しく構築されることを保証

**テスト項目:**
- [ ] ViewModel のフィールドが期待値で初期化される
- [ ] ViewModel がイミュータブルである（作成後に値が変わらない）
- [ ] 複数 ViewModel インスタンスが独立している

**テスト例:**
```nim
suite "LoginPageViewModel":
  test "ViewModel is initialized correctly":
    let vm = LoginPageViewModel.new(
      isLogin = true,
      name = "John",
      formParams = Params.new(),
      formErrors = @["Error 1"]
    )
    check vm.isLogin == true
    check vm.name == "John"
    check vm.formErrors[0] == "Error 1"

  test "Multiple ViewModels are independent":
    let vm1 = LoginPageViewModel.new(true, "John", ...)
    let vm2 = LoginPageViewModel.new(false, "Jane", ...)
    check vm1.isLogin == true
    check vm2.isLogin == false
```

## 3. バリデーションエラー表示テスト

**目的**: バリデーションエラーが正しく表示されることを保証

**テスト項目:**
- [ ] ViewModel にエラーリストが正しく格納される
- [ ] Template でエラーが正しく描画される
- [ ] エラーのない場合、リストが空である

**テスト例:**
```nim
suite "Validation Error Rendering":
  test "Errors are passed to ViewModel correctly":
    let errors = @["Name is required", "Password is too short"]
    let vm = LoginPageViewModel.new(false, "", Params.new(), errors)
    check vm.formErrors.len == 2
    check vm.formErrors[0] == "Name is required"
```

## 4. ログイン状態分岐表示テスト

**目的**: ログイン済み/未ログイン状態が正しく反映されることを保証

**テスト項目:**
- [ ] ログイン未状態（isLogin=false）で、ログインフォームが表示される
- [ ] ログイン済み状態（isLogin=true）で、ログイン情報が表示される
- [ ] ログイン済み状態で、ログアウトボタンが表示される

**テスト例:**
```nim
suite "Login State Branching":
  test "Not logged in: shows login form":
    let vm = LoginPageViewModel.new(isLogin = false, ...)
    let html = loginTemplate(vm)
    check html.contains("<h2>Login</h2>")
    check html.contains("<input type=\"text\" name=\"name\"")

  test "Logged in: shows user info":
    let vm = LoginPageViewModel.new(isLogin = true, name = "Alice", ...)
    let html = loginTemplate(vm)
    check html.contains("Alice")
    check html.contains("Logout")
```

## 5. フォーム旧値復元テスト

**目的**: バリデーションエラー時に、入力された旧値が復元されることを保証

**テスト項目:**
- [ ] `formParams.old("name")` で直前の入力値が取得できる
- [ ] バリデーションエラー後に、form fields が旧値で埋まる
- [ ] 新規フォーム表示時は旧値は空である

**テスト例:**
```nim
suite "Form Old Value Restoration":
  test "Old form values are restored on error":
    let params = Params.new()
    params["name"] = "testuser"
    let vm = LoginPageViewModel.new(
      isLogin = false,
      name = "",
      formParams = params,
      formErrors = @["Password required"]
    )
    check vm.formParams.old("name") == "testuser"
```

## 6. Page → Presenter → ViewModel データフロー テスト

**目的**: Page が正しく Presenter 経由で ViewModel を構築していることを保証

**テスト項目:**
- [ ] Page が Context から正しくパラメータを抽出する
- [ ] Page が Presenter を呼び出す
- [ ] Presenter が ViewModel を返す
- [ ] Template が ViewModel を受け取る

**テスト例:**
```nim
suite "Page Presenter ViewModel Flow":
  test "Page builds and passes ViewModel to template":
    # Mock context
    # Call loginPage()
    # Verify that loginTemplate is called with ViewModel
    # Verify HTML output is correct
```

## 7. Signal 廃止後の互換性テスト

**目的**: Signal 廃止が他のコンポーネントに影響しないこと

**テスト項目:**
- [ ] Signal 削除後も Template が正しく描画される
- [ ] Page → Template データフローが変わらない
- [ ] 既存ルートが引き続き動作する

**テスト例:**
```nim
suite "Post-Signal Migration":
  test "Login page works without signal":
    # GET /sample/login
    # Verify HTTP 200
    # Verify HTML contains "Login"

  test "Login form submission works":
    # POST /sample/login with name=testuser, password=pass
    # Verify response is valid
```

## 8. 回帰確認項目（手動テスト）

### 機能確認
- [ ] ログインページへのアクセス → フォーム表示
- [ ] フォーム入力（バリデーションエラー）→ エラーメッセージ表示、旧値復元
- [ ] 正常ログイン → リダイレクト、ログイン状態確認
- [ ] ログアウト → ログイン状態解除

### 並行テスト（複数ブラウザ）
- [ ] ユーザーA と ユーザーB が同時にログイン操作
- [ ] 互いのセッション情報が混線しないことを確認
- [ ] エラーメッセージが正しく分離されることを確認

### パフォーマンス確認
- [ ] メモリリーク（ViewModel 作成時）がないか
- [ ] 大量リクエスト後のメモリ使用量が安定しているか

## テスト実施スケジュール

1. **単体テスト**: ViewModel 構築ロジック
2. **統合テスト**: Page → Template データフロー
3. **E2E テスト**: ブラウザからの実際のログイン操作
4. **並行テスト**: 複数リクエスト同時実行

## 依存関係

- Basolato テストフレームワーク
- HTTP クライアントライブラリ（E2E テスト用）
- 並行テスト用の非同期ツール
