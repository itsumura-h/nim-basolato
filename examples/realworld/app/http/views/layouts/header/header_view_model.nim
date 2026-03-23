type HeaderViewModel*  = object
  isLogin*:bool
  pageUrl*:string


proc new*(_:type HeaderViewModel, isLogin:bool, pageUrl:string): HeaderViewModel =
  return HeaderViewModel(isLogin: isLogin, pageUrl: pageUrl)
