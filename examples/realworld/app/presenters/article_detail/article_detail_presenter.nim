import std/asyncdispatch
import basolato/view
import ../../models/dto/article_detail/article_detail_dao_interface
import ../../models/dto/user/user_dao_interface
import ../../http/views/templates/article/article_template_model
import ../../di_container


type ArticleDetailPresenter* = object
  articleDetailDao*: IArticleDetailDao
  userDao*: IUserDao

proc new*(_:type ArticleDetailPresenter): ArticleDetailPresenter =
  return ArticleDetailPresenter(
    articleDetailDao: di.articleDetailDao,
    userDao: di.userDao
  )


proc invoke*(self:ArticleDetailPresenter): Future[ArticleTemplateModel] {.async.} =
  let context = context()
  let articleId = context.params.getStr("articleId")

  let articleDetailDao:IArticleDetailDao = di.articleDetailDao
  let articleDetailDto = articleDetailDao.getArticleById(articleId).await

  let userDao:IUserDao = di.userDao
  let authorDto = userDao.getUserById(articleDetailDto.authorId).await

  let model = ArticleTemplateModel.new(articleDetailDto, authorDto).await
  return model
