type WelcomeTemplateModel* = object
  title*: string


proc new*(_: type WelcomeTemplateModel, title: string): WelcomeTemplateModel =
  return WelcomeTemplateModel(title: title)
