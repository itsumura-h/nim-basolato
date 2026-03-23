import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../presenters/welcome/welcome_page_viewmodel
import ../../templates/welcome/welcome_template


proc welcomePageView*(context: Context):Future[Component] {.async.} =
  let vm = WelcomePageViewModel.new()
  let page = welcomeTemplate(vm)
  return page
