
import std/asyncdispatch
import interface_implements
import ./article_detail_dto


interfaceDefs:
  type IArticleDetailDao* = object of RootObj
    getArticleById*: proc(self: IArticleDetailDao, articleId: string): Future[ArticleDetailDto]
