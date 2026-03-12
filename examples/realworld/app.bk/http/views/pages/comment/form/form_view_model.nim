type FormViewModel* = object
  articleId*:string
  userImage*:string

proc new*(_:type FormViewModel, articleId:string, userImage:string):FormViewModel =
  return FormViewModel(articleId:articleId, userImage:userImage)
