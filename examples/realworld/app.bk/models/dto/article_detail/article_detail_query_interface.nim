import std/asyncdispatch
import interface_implements
import ../../vo/article_id
import ./article_detail_dto

interfaceDefs:
  type IArticleDetailQuery* = object of RootObj
    invoke: proc(self:IArticleDetailQuery, articleId:ArticleId):Future[ArticleDetailDto]
