import std/asyncdispatch
import std/sequtils
import basolato/view
import ../../consts
import ../../di_container
import ../../models/dto/article_list/global_feed_article_list_dao_interface
import ../../models/dto/article_list/global_feed_article_count_dao_interface
import ../../models/dto/article_list/article_list_dto
import ../../http/views/templates/feed/feed_template_model
import ../../http/views/components/feed_article/feed_article_component_model
import ../../http/views/components/paginator/paginator_component_model


type GlobalFeedPresenter* = object
  articleListDao: IGlobalFeedArticleListDao
  articleCountDao: IGlobalFeedArticleCountDao

proc new*(_:type GlobalFeedPresenter):GlobalFeedPresenter =
  return GlobalFeedPresenter(
    articleListDao: di.globalFeedArticleListDao,
    articleCountDao: di.globalFeedArticleCountDao
  )


proc invoke*(self: GlobalFeedPresenter):Future[FeedTemplateModel] {.async.} =
  let context = context()
  let loginUserId = context.get("user_id").await
  let page = context.params.getInt("page", 1)
  let offset = (page - 1) * FEED_DISPLAY_COUNT

  let articleDtoList = self.articleListDao.invoke(offset, FEED_DISPLAY_COUNT).await

  let articleList = articleDtoList.map(
    proc(article:ArticleDto):FeedArticleComponentModel =
      let tagList = article.tagList.map(
        proc(tag:TagDto):string =
          tag.name
      )

      let isLoginUserLiked = article.popularUserIdList.contains(loginUserId)

      return FeedArticleComponentModel.new(
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

  let totalCount = self.articleCountDao.invoke().await

  let paginatorModel = PaginatorComponentModel.new(
    currentPage = page,
    total = totalCount,
  )

  let model = FeedTemplateModel.new(
    articleList = articleList,
    paginatorModel = paginatorModel,
    feedType = FeedType.global,
    tagName = ""
  )
  .await

  return model
