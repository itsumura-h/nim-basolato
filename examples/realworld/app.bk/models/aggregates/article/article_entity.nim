import std/times
import ../../vo/article_id
import ../../vo/title
import ../../vo/description
import ../../vo/body
import ../../vo/user_id
import ./tag_entity


type DraftArticle* = object
  articleId*: ArticleId
  title*: Title
  description*: Description
  body*: Body
  tags*:seq[Tag]
  userId*: UserId
  createdAt*:DateTime
  updatedAt*:DateTime


proc new*(_:type DraftArticle,
  title:Title,
  description:Description,
  body:Body,
  tags:seq[Tag],
  userId:UserId
): DraftArticle =
  let articleId = ArticleId.new(title)
  let now = now().utc()
  return DraftArticle(
    articleId: articleId,
    title: title,
    description:description,
    body: body,
    tags: tags,
    userId: userId,
    createdAt: now,
    updatedAt: now,
  )


type Article* = object
  articleId*: ArticleId
  title*: Title
  description*: Description
  body*: Body
  tags*:seq[Tag]
  userId*: UserId
  updatedAt*:DateTime

proc new*(_:type Article,
  articleId:ArticleId,
  title:Title,
  description:Description,
  body:Body,
  tags:seq[Tag],
  userId:UserId,
): Article =
  let now = now().utc()
  return Article(
    articleId: articleId,
    title: title,
    description:description,
    body: body,
    tags: tags,
    userId: userId,
    updatedAt: now,
  )
