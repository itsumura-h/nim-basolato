import ../../vo/article_id
import ../../vo/user_id


type Favorite* = object
  articleId*:ArticleId
  favoriteUserId*:UserId

proc new*(_:type Favorite, articleId:ArticleId, favoriteUserId:UserId): Favorite =
  return Favorite(
    articleId: articleId,
    favoriteUserId: favoriteUserId
  )
