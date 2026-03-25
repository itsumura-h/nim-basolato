import std/asyncdispatch
import basolato/view
import basolato/core/base
import ../../layouts/app/app_layout
import ../../layouts/app/app_layout_model
import ../../layouts/head/head_layout_model
import ../../templates/welcome/welcome_template
import ../../templates/welcome/welcome_template_model


proc welcomePageView*(context: Context):Future[Component] {.async.} =
  discard context
  let title = "Basolato " & BasolatoVersion
  let templateModel = WelcomeTemplateModel.new(title)
  let body = welcomeTemplate(templateModel)
  let headLayoutModel = HeadLayoutModel.new(title)
  let appLayoutModel = AppLayoutModel.new(headLayoutModel)
  return appLayout(appLayoutModel, body)
