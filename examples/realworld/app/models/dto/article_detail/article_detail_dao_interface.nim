
import std/asyncdispatch
import std/options
import interface_implements
import ./article_detail_dto


interfaceDefs:
  type IArticleDetailDao* = object of RootObj
    getArticleById*: proc(self: IArticleDetailDao, articleId: string, loginUserId: Option[string] = none(string)): Future[ArticleDetailDto]
