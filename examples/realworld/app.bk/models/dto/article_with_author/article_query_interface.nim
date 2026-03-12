import std/asyncdispatch
import interface_implements
import ../../vo/article_id
import ./article_with_author_dto

interfaceDefs:
  type IArticleQuery* = object of RootObj
    invoke:proc(self: IArticleQuery, articleId:ArticleId): Future[ArticleWithAuthorDto]
