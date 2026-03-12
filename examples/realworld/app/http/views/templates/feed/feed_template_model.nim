import std/asyncdispatch
import basolato/view
import ../../components/feed_article/feed_article_component_model
import ../../components/paginator/paginator_component_model


type FeedType* = enum
  global
  yourFeed
  tag

type FeedTemplateModel* = object
  isLogin*:bool
  articleList*:seq[FeedArticleComponentModel]
  feedType*:FeedType
  tagName*:string
  paginatorModel*:PaginatorComponentModel


proc new*(
  _:type FeedTemplateModel,
  articleList:seq[FeedArticleComponentModel],
  paginatorModel:PaginatorComponentModel,
  feedType:FeedType,
  tagName:string
):Future[FeedTemplateModel] {.async.} =
  let context = context()
  let isLogin = context.isLogin().await

  return FeedTemplateModel(
    isLogin: isLogin,
    articleList: articleList,
    paginatorModel: paginatorModel,
    feedType: feedType,
    tagName: tagName,
  )
