import std/asyncdispatch
import basolato/view
import ../../../../../config/consts
import ../../../../di_container
import ../../../../models/dto/article_list/tag_feed_article_count_dao_interface
import ../../../../models/dto/article_list/tag_feed_article_list_dao_interface
import ../../components/feed_article/feed_article_component_model
import ../../components/paginator/paginator_component_model
import ./feed_utils


type TagFeedTemplateModel* = object
  isLogin*: bool
  articleList*: seq[FeedArticleComponentModel]
  paginatorModel*: PaginatorComponentModel
  tagName*: string


proc new*(_: type TagFeedTemplateModel, context: Context): Future[TagFeedTemplateModel] {.async.} =
  let feedContext = await loadFeedContext(context)
  let tagName = context.params.getStr("tag")
  let articleDtoList = di.tagFeedArticleListDao.invoke(
    tagName,
    feedContext.offset,
    FEED_DISPLAY_COUNT,
  ).await
  let totalCount = di.tagFeedArticleCountDao.invoke(tagName).await
  let articleList = buildArticleList(articleDtoList, feedContext.loginUserId, context.csrfToken())
  let paginatorModel = PaginatorComponentModel.new(feedContext.page, totalCount)
  return TagFeedTemplateModel(
    isLogin: feedContext.isLogin,
    articleList: articleList,
    paginatorModel: paginatorModel,
    tagName: tagName,
  )
