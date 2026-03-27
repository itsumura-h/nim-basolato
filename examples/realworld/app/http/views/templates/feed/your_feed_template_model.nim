import std/asyncdispatch
import basolato/view
import ../../../../../config/consts
import ../../../../di_container
import ../../../../models/dto/article_list/your_feed_article_count_dao_interface
import ../../../../models/dto/article_list/your_feed_article_list_dao_interface
import ../../components/feed_article/feed_article_component_model
import ../../components/paginator/paginator_component_model
import ./feed_utils


type YourFeedTemplateModel* = object
  isLogin*: bool
  articleList*: seq[FeedArticleComponentModel]
  paginatorModel*: PaginatorComponentModel


proc new*(_: type YourFeedTemplateModel, context: Context): Future[YourFeedTemplateModel] {.async.} =
  let feedContext = await loadFeedContext(context)
  let articleDtoList = di.yourFeedArticleListDao.invoke(
    feedContext.loginUserId,
    feedContext.offset,
    FEED_DISPLAY_COUNT,
  ).await
  let totalCount = di.yourFeedArticleCountDao.invoke(feedContext.loginUserId).await
  let articleList = buildArticleList(articleDtoList, feedContext.loginUserId, context.csrfToken())
  let paginatorModel = PaginatorComponentModel.new(feedContext.page, totalCount, context.request.url.path)
  return YourFeedTemplateModel(
    isLogin: feedContext.isLogin,
    articleList: articleList,
    paginatorModel: paginatorModel,
  )
