import std/asyncdispatch
import std/json
import ../../../../../../../src/basolato/view
import ../../../../../../../src/basolato/core/security/cookie
import ./cookie_page_viewmodel


type CookiePagePresenter* = object


proc new*(_: type CookiePagePresenter): CookiePagePresenter =
  return CookiePagePresenter()


proc invoke*(self: CookiePagePresenter, context: Context): Future[CookiePageViewModel] {.async.} =
  # context からクッキー情報を取得
  let csrfToken = context.getCsrfToken()
  
  # クッキーを JSON として返す
  # Basolato の Cookies クラスを使用
  let cookieObj = Cookies.new(context.request).getAll()
  var cookiesJson = newJObject()
  for key, val in cookieObj.pairs:
    cookiesJson[key] = newJString(val)
  
  return CookiePageViewModel.new(cookiesJson, csrfToken)
