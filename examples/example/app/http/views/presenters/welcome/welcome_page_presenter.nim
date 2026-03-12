import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../../../../../../src/basolato/core/base
import ./welcome_page_viewmodel


type WelcomePagePresenter* = object


proc new*(_: type WelcomePagePresenter): WelcomePagePresenter =
  return WelcomePagePresenter()


proc invoke*(self: WelcomePagePresenter, context: Context): Future[WelcomePageViewModel] {.async.} =
  # context は使わずシンプルな ViewModel を返す
  return WelcomePageViewModel.new()
