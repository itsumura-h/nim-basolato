import std/asyncdispatch
import std/sequtils
import basolato/view
import ../../consts
import ../../di_container
import ../../models/dto/article_list/user_article_list_dao_interface
import ../../models/dto/article_list/user_article_count_dao_interface
import ../../models/dto/article_list/article_list_dto
import ../../http/views/templates/user_article_list/user_article_list_template_model
import ../../http/views/components/paginator/paginator_component_model
import ../../http/views/components/feed_article/feed_article_component_model


type UserArticleListPresenter* = object
  articleListDao*: IUserArticleListDao
  articleCountDao*: IUserArticleCountDao

proc new*(_:type UserArticleListPresenter): UserArticleListPresenter =
  return UserArticleListPresenter(
    articleListDao: di.userArticleListDao,
    articleCountDao: di.userArticleCountDao
  )


proc invoke*(self: UserArticleListPresenter):Future[UserArticleListTemplateModel] {.async.} =
  let context = context()
  let isLogin = context.isLogin().await
  let loginUserId = context.get("user_Id").await
  let userId = context.params.getStr("userId")
  let page = context.params.getInt("page", 1)
  let offset = (page - 1) * FEED_DISPLAY_COUNT

  let articleDtoList = self.articleListDao.invoke(userId, offset, FEED_DISPLAY_COUNT).await

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

  let totalCount = self.articleCountDao.invoke(userId).await

  let paginatorModel = PaginatorComponentModel.new(
    currentPage = page,
    total = totalCount,
  )

  let model = UserArticleListTemplateModel.new(
    isLogin = isLogin,
    userId = userId,
    articleList = articleList,
    paginatorModel = paginatorModel,
  )

  return model
