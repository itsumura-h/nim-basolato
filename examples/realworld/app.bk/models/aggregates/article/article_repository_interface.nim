import std/asyncdispatch
import interface_implements
import ../../vo/article_id
import ./article_entity

interfaceDefs:
  type IArticleRepository*  = object of RootObj
    isExists:proc(self:IArticleRepository, articleId:ArticleId):Future[bool]
    create:proc(self:IArticleRepository, article:DraftArticle):Future[void]
    update:proc(self:IArticleRepository, article:Article):Future[void]
    delete:proc(self:IArticleRepository, articleId:ArticleId):Future[void]
