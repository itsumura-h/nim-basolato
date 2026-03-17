import std/asyncdispatch
import std/sequtils
import basolato/view
import ../../../../consts
import ../../../../di_container
import ../../../../models/dto/article_list/global_feed_article_list_dao_interface
import ../../../../models/dto/article_list/global_feed_article_count_dao_interface
import ../../../../models/dto/article_list/your_feed_article_list_dao_interface
import ../../../../models/dto/article_list/your_feed_article_count_dao_interface
import ../../../../models/dto/article_list/tag_feed_article_list_dao_interface
import ../../../../models/dto/article_list/tag_feed_article_count_dao_interface
import ../../../../models/dto/article_list/article_list_dto
import ../../components/feed_article/feed_article_component_model
import ../../components/paginator/paginator_component_model


type FeedType* = enum
  global
  yourFeed
  tag

type FeedTemplateModel* = object
  isLogin*: bool
  articleList*: seq[FeedArticleComponentModel]
  feedType*: FeedType
  tagName*: string
  paginatorModel*: PaginatorComponentModel


proc new*(
  _: type FeedTemplateModel,
  isLogin: bool,
  articleList: seq[FeedArticleComponentModel],
  paginatorModel: PaginatorComponentModel,
  feedType: FeedType,
  tagName: string
): FeedTemplateModel =
  FeedTemplateModel(
    isLogin: isLogin,
    articleList: articleList,
    paginatorModel: paginatorModel,
    feedType: feedType,
    tagName: tagName,
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


proc new*(_: type FeedTemplateModel, context: Context): Future[FeedTemplateModel] {.async.} =
  let loginUserId = context.get("user_id").await
  let page = context.params.getInt("page", 1)
  let offset = (page - 1) * FEED_DISPLAY_COUNT
  let isLogin = context.isLogin().await
  let path = context.request.url.path

  if path == "/":
    let articleDtoList = di.globalFeedArticleListDao.invoke(offset, FEED_DISPLAY_COUNT).await
    let totalCount = di.globalFeedArticleCountDao.invoke().await
    let articleList = buildArticleList(articleDtoList, loginUserId)
    let paginatorModel = PaginatorComponentModel.new(page, totalCount)
    return FeedTemplateModel.new(isLogin, articleList, paginatorModel, FeedType.global, "")
  elif path == "/your-feed":
    let articleDtoList = di.yourFeedArticleListDao.invoke(loginUserId, offset, FEED_DISPLAY_COUNT).await
    let totalCount = di.yourFeedArticleCountDao.invoke(loginUserId).await
    let articleList = buildArticleList(articleDtoList, loginUserId)
    let paginatorModel = PaginatorComponentModel.new(page, totalCount)
    return FeedTemplateModel.new(isLogin, articleList, paginatorModel, FeedType.yourFeed, "")
  else:
    let tagId = context.params.getStr("tag")
    let articleDtoList = di.tagFeedArticleListDao.invoke(tagId, offset, FEED_DISPLAY_COUNT).await
    let totalCount = di.tagFeedArticleCountDao.invoke(tagId).await
    let articleList = buildArticleList(articleDtoList, loginUserId)
    let paginatorModel = PaginatorComponentModel.new(page, totalCount)
    return FeedTemplateModel.new(isLogin, articleList, paginatorModel, FeedType.tag, tagId)
