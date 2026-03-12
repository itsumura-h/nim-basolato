import std/asyncdispatch
import std/times
import basolato/view
import markdown
import ../../../../models/dto/article_detail/article_detail_dto
import ../../../../models/dto/user/user_dto


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
  author*:Author
  article*:Article
  isAuthor*:bool
  isLogin*:bool


proc new*(_: type ArticleTemplateModel, articleDetailDto:ArticleDetailDto, userDto:UserDto): Future[ArticleTemplateModel] {.async.} =
  let context = context()
  let isLogin = context.isLogin().await
  let loginUserId = context.get("user_id").await
  
  let author = Author(
    id: articleDetailDto.authorId,
    image: userDto.image,
    name: userDto.name,
    followerCount: userDto.followerCount,
  )

  let article = Article(
    title: articleDetailDto.title,
    content: articleDetailDto.content.markdown(),
    favoriteCount: articleDetailDto.favoriteCount,
    updatedAt: articleDetailDto.updatedAt.format("yyyy MMM d"),
  )

  let isAuthor = loginUserId == articleDetailDto.authorId

  return ArticleTemplateModel(
    author: author,
    article: article,
    isAuthor: isAuthor,
    isLogin: isLogin,
  )
