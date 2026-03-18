import std/times
import ../../vo/article_id
import ../../vo/user_id

type Comment* = object
  id*: int
  articleId*: ArticleId
  authorId*: UserId
  body*: string
  createdAt*: DateTime
  updatedAt*: DateTime

proc new*(_: type Comment,
  articleId: ArticleId,
  authorId: UserId,
  body: string,
): Comment =
  let now = now().utc()
  return Comment(
    id: 0,
    articleId: articleId,
    authorId: authorId,
    body: body,
    createdAt: now,
    updatedAt: now,
  )
