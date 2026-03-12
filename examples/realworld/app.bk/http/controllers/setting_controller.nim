import std/asyncdispatch
import std/options
import basolato/controller
import ../../presenters/app/app_presenter
import ../../presenters/setting/setting_presenter
import ../views/pages/setting/setting_view


proc index*(context:Context, parmas:Params):Future[Response] {.async.} =
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      return render(Http403, "Forbidden")

  let appPresenter = AppPresenter.new()
  let appViewModel = appPresenter.invoke(loginUserId, "Setting ― Conduit").await
  let settingPresenter = SettingPresenter.new()
  let settingViewModel = settingPresenter.invoke(loginUserId.get()).await
  let view = settingView(appViewModel, settingViewModel)
  return render(view)
