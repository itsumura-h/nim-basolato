type EditButtonViewModel* = object
  articleId*:string

proc new*(_:type EditButtonViewModel, articleId:string): EditButtonViewModel =
  return EditButtonViewModel(articleId: articleId)
