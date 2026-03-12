type CommentComponentModel* = object
  content*:string
  authorId*:string
  authorName*:string
  authorImage*:string
  createdAt*:string
  isAuthor*:bool

proc new*(
  _:type CommentComponentModel,
  content: string,
  authorId: string,
  authorName: string,
  authorImage: string,
  createdAt: string,
  isAuthor: bool,
): CommentComponentModel =
  return CommentComponentModel(
    content: content,
    authorId: authorId,
    authorName: authorName,
    authorImage: authorImage,
    createdAt: createdAt,
    isAuthor: isAuthor,
  )
