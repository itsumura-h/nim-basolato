import std/asyncdispatch
import basolato/view
import ../../../../../config/consts
import ../../../../di_container
import ../../../../models/dto/article_list/global_feed_article_count_dao_interface
import ../../../../models/dto/article_list/global_feed_article_list_dao_interface
import ../../components/feed_article/feed_article_component_model
import ../../components/paginator/paginator_component_model
import ./feed_utils


type GlobalFeedTemplateModel* = object
  isLogin*: bool
  articleList*: seq[FeedArticleComponentModel]
  paginatorModel*: PaginatorComponentModel


proc new*(_: type GlobalFeedTemplateModel, context: Context): Future[GlobalFeedTemplateModel] {.async.} =
  let feedContext = await loadFeedContext(context)
  let articleDtoList = di.globalFeedArticleListDao.invoke(feedContext.offset, FEED_DISPLAY_COUNT).await
  let totalCount = di.globalFeedArticleCountDao.invoke().await
  let articleList = buildArticleList(articleDtoList, feedContext.loginUserId, context.csrfToken())
  let paginatorModel = PaginatorComponentModel.new(feedContext.page, totalCount, context.request.url.path)
  return GlobalFeedTemplateModel(
    isLogin: feedContext.isLogin,
    articleList: articleList,
    paginatorModel: paginatorModel,
  )
