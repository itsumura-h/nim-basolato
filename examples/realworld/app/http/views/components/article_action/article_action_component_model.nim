import basolato/view

type ArticleActionComponentModel* = object
  articleId*: string
  authorId*: string
  authorName*: string
  authorImage*: string
  followerCount*: int
  isFollowed*: bool
  favoriteCount*: int
  isFavorited*: bool
  csrfToken*: CsrfToken
  isAuthor*: bool

proc new*(
  _: type ArticleActionComponentModel,
  articleId: string,
  authorId: string,
  authorName: string,
  authorImage: string,
  followerCount: int,
  isFollowed: bool,
  favoriteCount: int,
  isFavorited: bool,
  csrfToken: CsrfToken,
  isAuthor: bool
): ArticleActionComponentModel =
  return ArticleActionComponentModel(
    articleId: articleId,
    authorId: authorId,
    authorName: authorName,
    authorImage: authorImage,
    followerCount: followerCount,
    isFollowed: isFollowed,
    favoriteCount: favoriteCount,
    isFavorited: isFavorited,
    csrfToken: csrfToken,
    isAuthor: isAuthor
  )
