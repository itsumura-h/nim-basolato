import std/asyncdispatch
import std/times
import basolato/view
import markdown
import ../../../../models/dto/article_detail/article_detail_dao_interface
import ../../../../models/dto/article_detail/article_detail_dto
import ../../../../models/dto/user/user_dao_interface
import ../../../../models/dto/user/user_dto
import ../../../../di_container


type Author* = object
  id*:string
  image*:string
  name*:string
  followerCount*:int

type Article* = object
  title*:string
  content*:string
  favoriteCount*:int
  updatedAt*:string
  tagList*:seq[string]

type ArticleTemplateModel* = object
  articleId*: string
  author*:Author
  article*:Article
  isAuthor*:bool
  isLogin*:bool
  csrfToken*: CsrfToken


proc new*(_: type ArticleTemplateModel, context: Context): Future[ArticleTemplateModel] {.async.} =
  let articleId = context.params.getStr("articleId")
  let articleDetailDto = di.articleDetailDao.getArticleById(articleId).await
  let authorDto = di.userDao.getUserById(articleDetailDto.authorId).await
  let isLogin = context.isLogin().await
  let loginUserId = context.get("user_id").await
  let csrfToken = context.csrfToken()

  let author = Author(
    id: articleDetailDto.authorId,
    image: authorDto.image,
    name: authorDto.name,
    followerCount: authorDto.followerCount,
  )

  let article = Article(
    title: articleDetailDto.title,
    content: articleDetailDto.content.markdown(),
    favoriteCount: articleDetailDto.favoriteCount,
    updatedAt: articleDetailDto.updatedAt.format("yyyy MMM d"),
    tagList: @[],
  )

  let isAuthor = loginUserId == articleDetailDto.authorId

  return ArticleTemplateModel(
    articleId: articleId,
    author: author,
    article: article,
    isAuthor: isAuthor,
    isLogin: isLogin,
    csrfToken: csrfToken,
  )
