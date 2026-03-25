import std/asyncdispatch
import std/sequtils
import basolato/view
import ../../../../../config/consts
import ../../../../models/dto/article_list/article_list_dto
import ../../components/feed_article/feed_article_component_model


proc buildArticleList*(
  articleDtoList: seq[ArticleDto],
  loginUserId: string,
  csrfToken: CsrfToken,
): seq[FeedArticleComponentModel] =
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
        csrfToken = csrfToken,
        tagList = tagList,
      )
  )


proc loadFeedContext*(
  context: Context,
): Future[tuple[loginUserId: string, page: int, offset: int, isLogin: bool]] {.async.} =
  let loginUserId = context.get("user_id").await
  let page = context.params.getInt("page", 1)
  let offset = (page - 1) * FEED_DISPLAY_COUNT
  let isLogin = context.isLogin().await
  return (
    loginUserId: loginUserId,
    page: page,
    offset: offset,
    isLogin: isLogin,
  )
