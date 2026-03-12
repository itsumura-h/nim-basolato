
import std/asyncdispatch
import interface_implements
import ./article_list_dto


interfaceDefs:
  type IGlobalFeedArticleListDao* = object of RootObj
    invoke*: proc(
        self:IGlobalFeedArticleListDao,
        offset:int,
        display:int,
      ):Future[seq[ArticleDto]]
