import std/asyncdispatch
import std/sequtils
import basolato/view
import ../../../../consts
import ../../../../di_container
import ../../../../models/dto/article_list/user_article_list_dao_interface
import ../../../../models/dto/article_list/user_article_count_dao_interface
import ../../../../models/dto/article_list/article_list_dto
import ../../components/feed_article/feed_article_component_model
import ../../components/paginator/paginator_component_model


type UserArticleListTemplateModel* = object
  isLogin*: bool
  userId*: string
  articleList*: seq[FeedArticleComponentModel]
  paginatorModel*: PaginatorComponentModel
  isFavorite*: bool


proc new*(
  _: type UserArticleListTemplateModel,
  isLogin: bool,
  userId: string,
  articleList: seq[FeedArticleComponentModel],
  paginatorModel: PaginatorComponentModel,
  isFavorite: bool = false,
): UserArticleListTemplateModel =
  UserArticleListTemplateModel(
    isLogin: isLogin,
    userId: userId,
    articleList: articleList,
    paginatorModel: paginatorModel,
    isFavorite: isFavorite,
  )


proc buildArticleList(articleDtoList: seq[ArticleDto], loginUserId: string): seq[FeedArticleComponentModel] =
  articleDtoList.map(
    proc(article: ArticleDto): FeedArticleComponentModel =
      let tagList = article.tagList.map(proc(tag: TagDto): string = tag.name)
      let isLoginUserLiked = article.popularUserIdList.contains(loginUserId)
      FeedArticleComponentModel.new(
        articleId = article.id,
        title = article.title,
        description = article.description,
        createdAt = article.createdAt,
        authorId = article.author.id,
        authorName = article.author.name,
        authorImage = article.author.image,
        popularCount = article.popularUserIdList.len,
        isLoginUserLiked = isLoginUserLiked,
        tagList = tagList,
      )
  )


proc new*(_: type UserArticleListTemplateModel, context: Context): Future[UserArticleListTemplateModel] {.async.} =
  let isLogin = context.isLogin().await
  let loginUserId = context.get("user_id").await
  let userId = context.params.getStr("userId")
  let page = context.params.getInt("page", 1)
  let offset = (page - 1) * FEED_DISPLAY_COUNT
  let path = context.request.url.path
  let isFavorite = path.endsWith("/favorite")

  if isFavorite:
    let articleDtoList = di.userFavoriteArticleListDao.invoke(userId, offset, FEED_DISPLAY_COUNT).await
    let totalCount = di.userFavoriteArticleCountDao.invoke(userId).await
    let articleList = buildArticleList(articleDtoList, loginUserId)
    let paginatorModel = PaginatorComponentModel.new(page, totalCount)
    return UserArticleListTemplateModel.new(isLogin, userId, articleList, paginatorModel, true)
  else:
    let articleDtoList = di.userArticleListDao.invoke(userId, offset, FEED_DISPLAY_COUNT).await
    let totalCount = di.userArticleCountDao.invoke(userId).await
    let articleList = buildArticleList(articleDtoList, loginUserId)
    let paginatorModel = PaginatorComponentModel.new(page, totalCount)
    return UserArticleListTemplateModel.new(isLogin, userId, articleList, paginatorModel, false)
