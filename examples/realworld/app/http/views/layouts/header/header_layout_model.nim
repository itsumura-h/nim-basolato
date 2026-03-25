type HeaderLayoutModel* = object
  isLogin*: bool
  pageUrl*: string


proc new*(_: type HeaderLayoutModel, isLogin: bool, pageUrl: string): HeaderLayoutModel =
  return HeaderLayoutModel(isLogin: isLogin, pageUrl: pageUrl)
