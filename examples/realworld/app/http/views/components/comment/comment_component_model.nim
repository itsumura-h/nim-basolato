import basolato/view

type CommentComponentModel* = object
  commentId*: int
  articleId*: string
  csrfToken*: CsrfToken
  content*:string
  authorId*:string
  authorName*:string
  authorImage*:string
  createdAt*:string
  isAuthor*:bool

proc new*(
  _:type CommentComponentModel,
  commentId: int,
  articleId: string,
  csrfToken: CsrfToken,
  content: string,
  authorId: string,
  authorName: string,
  authorImage: string,
  createdAt: string,
  isAuthor: bool,
): CommentComponentModel =
  return CommentComponentModel(
    commentId: commentId,
    articleId: articleId,
    csrfToken: csrfToken,
    content: content,
    authorId: authorId,
    authorName: authorName,
    authorImage: authorImage,
    createdAt: createdAt,
    isAuthor: isAuthor,
  )
