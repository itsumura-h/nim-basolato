import ../../components/feed_article/feed_article_component_model
import ../../components/paginator/paginator_component_model


type UserArticleListTemplateModel* = object
  isLogin*:bool
  userId*:string
  articleList*:seq[FeedArticleComponentModel]
  paginatorModel*:PaginatorComponentModel

proc new*(
  _:type UserArticleListTemplateModel,
  isLogin: bool,
  userId: string,
  articleList: seq[FeedArticleComponentModel],
  paginatorModel: PaginatorComponentModel,
): UserArticleListTemplateModel =
  return UserArticleListTemplateModel(
    isLogin: isLogin,
    userId: userId,
    articleList: articleList,
    paginatorModel: paginatorModel,
  )
