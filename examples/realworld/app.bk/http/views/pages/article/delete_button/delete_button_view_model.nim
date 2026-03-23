type DeleteButtonViewModel* = object
  articleId*:string

proc new*(_:type DeleteButtonViewModel, articleId:string): DeleteButtonViewModel =
  return DeleteButtonViewModel(articleId: articleId)
